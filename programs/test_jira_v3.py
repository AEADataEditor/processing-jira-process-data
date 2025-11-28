#!/usr/bin/env python3
"""
Test script to verify JIRA v3 API connectivity and functionality
"""
import os
import sys
from jira import JIRA
from dotenv import load_dotenv

def test_jira_connection():
    """Test basic JIRA v3 API connection"""
    
    # Load environment variables
    load_dotenv()
    
    username = os.environ.get('JIRA_USERNAME')
    api_key = os.environ.get('JIRA_API_KEY')
    jiradomain = "https://aeadataeditors.atlassian.net"
    
    if not username or not api_key:
        print("Please set JIRA_USERNAME and JIRA_API_KEY environment variables")
        return False
    
    try:
        # Initialize JIRA connection with v3 API
        print("Connecting to JIRA...")
        jira = JIRA(server=jiradomain, basic_auth=(username, api_key))
        
        # Test basic functionality
        print("Testing fields endpoint...")
        fields = jira.fields()
        print(f"Successfully retrieved {len(fields)} fields")
        
        # Test search functionality with a simple query
        print("Testing search endpoint...")
        issues = jira.search_issues('project = AEAREP', startAt=0, maxResults=1)
        print(f"Successfully retrieved {len(issues)} issues from search")
        
        if issues:
            # Test issue detail retrieval with changelog
            issue_key = issues[0].key
            print(f"Testing issue detail retrieval for {issue_key}...")
            issue = jira.issue(issue_key, expand='changelog')
            print(f"Successfully retrieved issue {issue_key} with {len(issue.changelog.histories)} history entries")
            
            # Test changelog item structure
            if issue.changelog.histories:
                history = issue.changelog.histories[0]
                print(f"Testing changelog structure...")
                for item in history.items:
                    # Test both old and new API formats
                    from_value = getattr(item, 'fromString', getattr(item, 'from', None))
                    to_value = getattr(item, 'toString', getattr(item, 'to', None))
                    print(f"  Field: {item.field}, From: {from_value}, To: {to_value}")
                    break  # Just test first item
        
        print("All JIRA v3 API tests passed!")
        return True
        
    except Exception as e:
        print(f"JIRA API test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_jira_connection()
    sys.exit(0 if success else 1)