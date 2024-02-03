#!/usr/bin/env python
import os
import csv
import json
import argparse 
from datetime import datetime
from datetime import timedelta
import pandas as pd
from dotenv import load_dotenv
from jira import JIRA


# find root directory based on either git or something elseroot_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def get_rootdir():
    """Get root directory of project"""

    cwd = os.getcwd()
    while cwd != os.path.dirname(cwd):
        if os.path.exists(os.path.join(cwd, '.git')):
            repo_root = cwd
            break
        cwd = os.path.dirname(cwd)
    return repo_root


# define the fields we are interested in
def get_fields(fieldfile):
    """Get fields to extract from excel file"""

    # Read excel file 
    df = pd.read_excel(fieldfile)  

    # Filter to only include fields set to True
    included_fields = df.loc[df['Include'] == True, 'Id'].tolist()
    # Create a list of the "Name" values
    names = df.loc[df['Include'] == True, 'Name'].tolist()

    # Add required system fields    
    included_fields.extend(['issue_key', 'As Of Date', 'Changed Fields'])
    names.extend(['Key', 'As Of Date', 'Changed Fields'])
    print(f"Fields to extract: {included_fields}")

    # Create a dictionary where the keys are the "Id" and the values are the "Name"
    id_to_name = df.set_index('Id')['Name'].to_dict()

    return included_fields, id_to_name, names

def jira_username():
    """Retrieve Jira username securely from env or prompt"""
    
    username = os.environ.get('JIRA_USERNAME')
    if not username:
        try:
            load_dotenv()
            username = os.environ.get("JIRA_USERNAME")
        except FileNotFoundError:
            print("Warning: .env file not found")
            username = False

    if not username:
        username = input("Enter Jira username: ")
    return username

def get_api_key():
    """Retrieve API key securely from env or prompt"""
    
    key = os.environ.get('JIRA_API_KEY')
    if not key:
        try:
            load_dotenv()
            key = os.environ.get("JIRA_API_KEY")
        except FileNotFoundError:
            print("Warning: .env file not found")
            key = False

    if not key:
        key = input("Enter Jira API key: ")
    return key

def get_issues(jira, start_date, end_date):
    """Get issues between two dates"""

    start = 0
    batch_size = 100
    jql = f"createdDate>='{start_date}' AND createdDate<='{end_date}' ORDER BY createdDate DESC"

    all_issues = []

    while True:
        print(f"Fetching batch {start}/{batch_size}")
        issues = jira.search_issues(jql, start, batch_size)
        # Store batch 
        all_issues.extend(issues)  

        start += batch_size
        if len(issues) < batch_size:
            break

    # write out debug file
    with open(f"issues.json", "w") as f:
        issues_as_dicts = [issue.raw for issue in all_issues]
        json.dump(issues_as_dicts, f)

    # return list of issue keys
    # Extract issue keys    
    issue_keys = [issue.key for issue in all_issues]
    print(f"Total issues fetched: {len(issue_keys)}")
    return issue_keys

def get_issue_history(jira, issue_key, fields):
    """Get full changelog for issue"""

    # Start from the complete state of the JIRA ticket, then walk backwards in the 'changelog' when recording changes.

    issue = jira.issue(issue_key, expand='changelog')

    # Initialize state with most recent values
        
    state = {f: getattr(issue.fields, f) if hasattr(issue.fields, f) else None for f in fields}
    
    state['Resolved'] = issue.fields.resolutiondate
    
    state['Key'] = issue_key

    # Change the formatting of the 'subtasks' field (to more easily work with R code)
    subtasks = getattr(issue.fields, 'subtasks')
    # Extract the keys of the sub-tasks that begin with 'AEAREP-'
    subtask_keys = [subtask.key for subtask in subtasks if subtask.key.startswith('AEAREP-')]
    # Convert subtask_keys to a string to remove brackets
    subtask_keys = ', '.join(subtask_keys)
    # Initialize the 'subtasks' field with the new string
    state['subtasks'] = subtask_keys

    # Change the formatting of the 'MCStatus' field (to more easily work with R code)
    mcstatuses = getattr(issue.fields, 'customfield_10061')
    # Check if mcstatuses is a list
    if isinstance(mcstatuses, list):
        # Check if the first element in mcstatuses is a string that contains "JIRA CustomFieldOption"
        if mcstatuses and "JIRA CustomFieldOption" in str(mcstatuses[0]):
            # Extract the value from each string in mcstatuses using a regular expression
            mcstatuses = [re.search("value='(.*?)'", str(mcstatus)).group(1) for mcstatus in mcstatuses if mcstatus is not None]
        else:
            # If the first element in mcstatuses does not contain "JIRA CustomFieldOption", use the list as is
            mcstatuses = [str(mcstatus) for mcstatus in mcstatuses if mcstatus is not None]
    else:
        # If mcstatuses is not a list, convert it to a list with a single element
        mcstatuses = [str(mcstatuses)] if mcstatuses is not None else []
    # Convert mcstatuses to a string, without brackets
    mcstatuses = ', '.join(mcstatuses)
    # Initialize the 'MCStatus' field with the new string
    state['customfield_10061'] = mcstatuses

    # Keep a record of the last toString value for each field
    last_toString_values = {} 

    histories = list(issue.changelog.histories)
    
    # Store the original creation date of the issue to prepare for split between the 'created' and 'As Of Date' fields
    original_created_date = histories[-1].created
    
    state['created'] = original_created_date

    state['As Of Date'] = histories[0].created

    # Initialize 'Changed Fields'
    first_items = histories[0].items
    first_changes = [item.field for item in first_items]
    state['Changed Fields'] = ', '.join(first_changes)

    # Initialize custom (i.e.'Start Date', 'Non-compliant', and 'Candidate for Best Package') fields
    state['customfield_10016'] = getattr(issue.fields, 'customfield_10016', None)
    state['customfield_10090'] = getattr(issue.fields, 'customfield_10090', None)
    state['customfield_10069'] = getattr(issue.fields, 'customfield_10069', None)

    all_states = [state.copy()]

    # Iterate over the reversed histories
    for history in histories:

        # Create a new state for the current history
        new_state = all_states[-1].copy()
        
        new_state['Key'] = issue_key

        # Update 'As Of Date' with the original 'created' field
        new_state['As Of Date'] = history.created

        # Add a new 'created' object that stores only the creation date of the original issue
        new_state['created'] = original_created_date

        new_state['subtasks'] = subtask_keys

        # Add custom fields to the new state
        new_state['customfield_10016'] = getattr(issue.fields, 'customfield_10016', None)
        new_state['customfield_10090'] = getattr(issue.fields, 'customfield_10090', None)
        new_state['customfield_10069'] = getattr(issue.fields, 'customfield_10069', None)

        # List to keep track of the fields that change in this history
        changed_fields = []

        for item in history.items:

            if item.fromString != item.toString:

                # If the field is not in new_state, add it
                if item.field not in new_state:
                    new_state[item.field] = None

                # If fromString matches the last toString value, use toString to update the field
                if item.fromString == last_toString_values.get(item.field):
                    new_state[item.field] = item.toString
                else:
                    new_state[item.field] = item.fromString

                # Update the last toString value for the field
                last_toString_values[item.field] = item.toString      

                # Add the field to the list of changed fields
                changed_fields.append(item.field)

        # Join the list of changed fields into a string separated by commas and add it to new_state
        new_state['Changed Fields'] = ', '.join(changed_fields)

        # After updating the state based on the items of a history, append a copy of the state to all_states
        all_states.append(new_state)  

    return all_states
     

def output_to_files(all_states,fulloutfile):
    """Output to CSV"""

    flat_states = [item for sublist in all_states for item in sublist]
  
    with open(fulloutfile, 'w', encoding="utf-8") as f:

        writer = csv.DictWriter(f, fieldnames=names)

        writer.writeheader()
        for state in flat_states:
            # Only keep keys that are in fieldnames
            filtered_state = {k: v for k, v in state.items() if k in names}
            writer.writerow(filtered_state)        

        
def print_summary(start_date, end_date, jiradomain, fulloutfile):
    """Print summary of what we are about to do"""

    print(f"Summary:")
    print(f"- Start Date: {start_date}")
    print(f"- End Date: {end_date}")
    print("")
    print(f" About to extract all issue history between these dates from {jiradomain}.")
    print(f" The output will be written to {fulloutfile}.")
    print("")
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Extract Jira issue history")
    parser.add_argument("-s", "--start", required=False, default="today", help="Start date in YYYY-MM-DD format")
    parser.add_argument("-e", "--end", required=False, default="today", help="End date in YYYY-MM-DD format")
    parser.add_argument("-d", "--domain", required=False, default="https://aeadataeditors.atlassian.net", help="Jira domain")
    parser.add_argument("-f", "--fieldfile", required=False, default="jira-fields.xlsx", help="Excel file with fields to extract")
    parser.add_argument("-o", "--outfile", required=False, default="issue_history.csv", help="Output file. Date will be appended to the filename.")

    args = parser.parse_args()

    start_date = args.start 
    end_date = args.end
    jiradomain = args.domain
    fieldfile = args.fieldfile
    fieldfiledir = os.path.join(get_rootdir(), "data","metadata")
    fieldfile = os.path.join(fieldfiledir, fieldfile)

    outfile = args.outfile
    # append date in isoformat to outfile
    outfile = outfile.replace(".csv", f"_{datetime.now().date().isoformat()}.csv")

    # append "data" and "confidential" to the outdir
    outdir = os.path.join(get_rootdir(), "data", "confidential")
    # check that it exists
    if not os.path.exists(outdir):
        os.makedirs(outdir)

    # now create the full path name for the output file 
    fulloutfile = os.path.join(outdir, outfile)

    # if the start or end date is "today" then we need to replace it with today's date
    # if start is "today", we subtract 7 days
    # if end is "today", we use today's date

    if args.start== "today":
        start_date = (datetime.now().date() - timedelta(days=7)).isoformat()
    if args.end == "today":
        end_date = datetime.now().date().isoformat()
    
    # summarize
    print_summary(start_date, end_date, jiradomain, fulloutfile)

    # check whether the outfile exists, and if yes, prompt to delete it or exit
    if os.path.exists(fulloutfile):
        print(f"Warning: {fulloutfile} already exists.")
        print(f"Proceeding will overwrite the file.")
  
    confirm = input("Proceed? (y/N): ")
    if confirm.lower() != "y":
        exit()

    options = {
    "server": jiradomain
     }
    
    # we get the fields from the excel file

    fields, id_to_name, names = get_fields(fieldfile)


    jira = JIRA(options, basic_auth=(jira_username(), get_api_key()))

    issue_keys = get_issues(jira, start_date, end_date)

    all_states = []

    for key in issue_keys:
        print(f"Fetching history for {key}")
        histories = get_issue_history(jira, key,fields)
        all_states.append(histories)
    for i in range(len(all_states)):
        for j in range(len(all_states[i])):
            # For each state in all_states, create a new dictionary where the keys are replaced according to the mapping
            new_state = {id_to_name.get(k, k): v for k, v in all_states[i][j].items()}
            # Replace the old state with the new state
            all_states[i][j] = new_state    
    output_to_files(all_states,fulloutfile)
    # confirm file is there
    if not os.path.exists(fulloutfile):
        print(f"Error: {fulloutfile} not found.")
    else:
        print(f"Output written to {fulloutfile}")
