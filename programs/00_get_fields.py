#!/usr/bin/env python
from jira import JIRA
import pandas as pd
import openpyxl
import os
import argparse
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

    options = {
    "server": jiradomain
     }

    jira = JIRA(options, basic_auth=(username, api_token))
    fields = jira.fields()

    # Extract field names and ids
    field_data = []
    for f in fields:
        field_data.append([f['name'], f['id']])

    return field_data

def export_fields(field_data, filename):
    # Convert to DataFrame    
    df = pd.DataFrame(field_data, columns=['Name', 'Id'])
    # make Include true everwhere
    df['Include'] = True

    # Export to Excel   
    # Check if file exists
    file_exists = os.path.isfile(filename)

    if file_exists and not overwrite_file:
        print('File already exists, not overwriting.')
    else:
        df.to_excel(filename, index=False)



def print_summary(filename, jiradomain):
    print(f"Summary:")
    print("")
    print(f" About to update the field catalog for {jiradomain}.")
    print(f" Writing to " + filename)
    print("")
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Extract Jira issue history")
    parser.add_argument("-f", "--filename", required=False, default="jira-fields.xlsx", help="Filename to output")
    parser.add_argument("-d", "--domain", required=False, default="https://aeadataeditors.atlassian.net", help="Jira domain")
    parser.add_argument("-o", "--overwrite", required=False, default="True", help="Overwrite the output file? True/False")
    args = parser.parse_args()

    filename = args.filename
    jiradomain = args.domain
    overwrite_file = args.overwrite

    
    # summarize
    print_summary(filename, jiradomain)
  
    confirm = input("Proceed? (y/N): ")
    if confirm.lower() != "y":
        exit()

    data = get_fields(jira_username(),get_api_key(),jiradomain)
    export_fields(data, filename)
