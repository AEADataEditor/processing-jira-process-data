#!/usr/bin/env python3
# Updated for JIRA v3 API compatibility
# Requires Python 3.6+ for f-string support
import os
import argparse
from jira import JIRA
import pandas as pd
from dotenv import load_dotenv

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

# find root directory based on either git or something else
def get_rootdir():
    """Get root directory of project"""

    cwd = os.getcwd()
    while cwd != os.path.dirname(cwd):
        if os.path.exists(os.path.join(cwd, '.git')):
            repo_root = cwd
            break
        cwd = os.path.dirname(cwd)
    return repo_root


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

def get_fields(username,api_token,jiradomain):

    # Initialize JIRA connection with v3 API
    jira = JIRA(server=jiradomain, basic_auth=(username, api_token))
    fields = jira.fields()

    # Extract field names and ids
    field_data = []
    for f in fields:
        field_data.append([f['name'], f['id']])

    return field_data

def export_fields(field_data, filename, include_fields="all"):
    # If include_fields is None or an empty list, print an error message and return
    if not include_fields:
        print("Error: No fields have been included.")
        return
    
    # Convert to DataFrame    
    df = pd.DataFrame(field_data, columns=['Name', 'Id'])

    # If include_fields is "all", make 'Include' true for all fields
    if include_fields == "all":
        df['Include'] = True
    # If include_fields is not "all", make 'Include' true only for the fields in include_fields
    else:
        df['Include'] = df['Name'].isin(include_fields)

    # Export to CSV   
    print('Check if file exists')
    file_exists = os.path.isfile(filename)

    if file_exists and not overwrite_file:
        print('File already exists, not overwriting.')
    else:
        print('Writing to ' + filename)
        df.to_csv(filename, index=False)


def print_summary(filename, jiradomain):
    print(f"Summary:")
    print("")
    print(f" About to update the field catalog for {jiradomain}.")
    print(f" Writing to " + filename)
    print("")
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Define fields to be included in query")
    parser.add_argument("-f", "--filename", required=False, default="jira-fields.csv", help="Filename to output")
    parser.add_argument("-d", "--domain", required=False, default="https://aeadataeditors.atlassian.net", help="Jira domain")
    parser.add_argument("-o", "--overwrite", required=False, default="True", help="Overwrite the output file? True/False")
    args = parser.parse_args()

    filename = args.filename
    jiradomain = args.domain
    overwrite_file = args.overwrite

    fieldfiledir = os.path.join(get_rootdir(), "data","metadata")
    fieldfile = os.path.join(fieldfiledir, filename)
    # Select fields based on past submissions
    include_fields = ["Resolution", "MCStatus", "MCRecommendationV2", "Reason for Failure to be Fully Reproduced",
                      "External validation", "External party name", "Assignee", "Status","MCRecommendation", 
                      "Sub-tasks", "openICPSR Project Number", "Issue Type", "Manuscript Central identifier", 
                      "Journal", "Software used", "Non-compliant", "Resolved", "Created","Key", "Update type",
                      "DCAF_Access_Restrictions", "DCAF_Access_Restrictions_V2","Agreement signed"]
    
    # summarize
    print_summary(fieldfile, jiradomain)
  
    confirm = input("Proceed? (y/N): ")
    if confirm.lower() != "y":
        exit()

    data = get_fields(jira_username(),get_api_key(),jiradomain)
    # If all (rather than only past submissions') fields are needed, remove the argument 'include_fields')
    export_fields(data, fieldfile, include_fields)
