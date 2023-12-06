#!/usr/bin/env python
import os
from jira import JIRA
import csv
import json
from dotenv import load_dotenv
import argparse 
from datetime import datetime
from datetime import timedelta
import pandas as pd

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
    included_fields = df.loc[df['Include'] == True, 'Name'].tolist()

    # Add required system fields    
    included_fields.extend(['issue_key', 'created'])
    print(f"Fields to extract: {included_fields}")

    return included_fields

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

def get_issue_history(jira, issue_key,fields):
    """Get full changelog for issue"""

    issue = jira.issue(issue_key, expand='changelog') 

    # Initialize state 
    all_states = []
    state = {f: None for f in fields}
    state['Resolved'] = issue.fields.resolutiondate
    # now walk through histories and compile the state at each point in time.
    for h in issue.changelog.histories:
        state['issue_key'] = issue_key
        state['created'] = h.created
        for item in h.items:
            if item.field == 'assignee':
                state['Assignee'] = item.toString
            if item.field == "issuetype":
                state["Issue Type"] = item.toString
            if item.field in fields:              
                state[item.field] = item.toString

        # Add the state to the list
        all_states.append(state.copy())
    
    return all_states
        
     

def output_to_files(all_states,fulloutfile):
    """Output to CSV"""

    flat_states = [item for sublist in all_states for item in sublist]
  
    with open(fulloutfile, 'w', encoding="utf-8") as f:

        writer = csv.DictWriter(f, fieldnames=fields)  
        writer.writeheader()
        writer.writerows(flat_states)

        
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

    fields = get_fields(fieldfile)


    jira = JIRA(options, basic_auth=(jira_username(), get_api_key()))

    issue_keys = get_issues(jira, start_date, end_date)
    all_states = []

    for key in issue_keys:
        print(f"Fetching history for {key}")
        histories = get_issue_history(jira, key,fields)
        all_states.append(histories)
    output_to_files(all_states,fulloutfile)