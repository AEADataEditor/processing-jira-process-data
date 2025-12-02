#!/usr/bin/env python3
# Updated for JIRA v3 API compatibility
# Requires Python 3.6+ for f-string support
import os
import csv
import json
import argparse 
import re
from datetime import datetime
from datetime import timedelta
import pandas as pd
from dotenv import load_dotenv
from jira import JIRA
import logging


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


# define the fields we are interested in
def log_and_print(message, verbose=False, logger=None, force_print=False):
    """Log message and optionally print to terminal"""
    if logger:
        logger.info(message)
    if verbose or force_print:
        print(message)

def get_fields(fieldfile):
    """Get fields to extract from CSV file"""

    # Read CSV file 
    df = pd.read_csv(fieldfile)  

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

def get_issues(jira, start_date, end_date, verbose=False, logger=None):
    """Get issues between two dates using simple count query approach"""
    
    # Convert date strings to datetime objects for CSV filename
    start_dt = datetime.strptime(start_date, '%Y-%m-%d')
    end_dt = datetime.strptime(end_date, '%Y-%m-%d')
    
    # Build the JQL query
    base_jql = f"project = AEAREP AND createdDate>='{start_date}' AND createdDate<='{end_date}' AND issuetype = Task ORDER BY createdDate DESC"
    
    print(f"Query: {base_jql}")
    
    try:
        # First, get the expected total count for comparison
        print("Getting expected total count for comparison...")
        try:
            # Try to get count using enhanced_search_issues 
            temp_issues = jira.enhanced_search_issues(base_jql.replace('ORDER BY createdDate DESC', ''))
            expected_count = len(temp_issues)
            print(f"Expected total issues (from enhanced_search_issues): {expected_count}")
        except Exception as e:
            print(f"Could not get expected count: {e}")
            expected_count = "Unknown"
        
        # Also try using search_issues for count comparison
        try:
            import warnings
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                count_result = jira.search_issues(base_jql.replace('ORDER BY createdDate DESC', ''), startAt=0, maxResults=0)
                api_total_count = count_result.total
                print(f"Expected total issues (from search_issues API): {api_total_count}")
        except Exception as e:
            print(f"Could not get API count: {e}")
            api_total_count = "Unknown"
        
        print("=" * 60)
        print("Now using daily chunked retrieval to get EXACT count...")
        print("=" * 60)
        
        # Process day by day to ensure we get every single issue
        all_issues = []
        current_date = datetime.fromisoformat(start_date).date()
        final_date = datetime.fromisoformat(end_date).date()
        
        total_days = (final_date - current_date).days + 1
        day_count = 0
        
        while current_date <= final_date:
            day_count += 1
            day_str = current_date.isoformat()
            
            progress_msg = f"Processing day {day_count}/{total_days}: {day_str}"
            if not verbose:
                print(f"\r{progress_msg}", end="", flush=True)
            log_and_print(progress_msg, verbose, logger)
            
            # Build JQL for this single day using range (>= and <)
            next_day_str = (current_date + timedelta(days=1)).isoformat()
            day_jql = f"project = AEAREP AND createdDate>='{day_str}' AND createdDate<'{next_day_str}' AND issuetype = Task ORDER BY createdDate DESC"
            
            try:
                # Use enhanced_search_issues for this day
                day_issues = jira.enhanced_search_issues(day_jql)
                if len(day_issues) > 0:
                    detail_msg = f"  Retrieved {len(day_issues)} issues on {day_str}"
                    log_and_print(detail_msg, verbose, logger)
                    all_issues.extend(day_issues)
                
                # If we still hit limits on a single day, fall back to smaller batches
                if len(day_issues) >= 100:
                    warn_msg = f"  Warning: Single day {day_str} has {len(day_issues)} issues - may have hit limit"
                    fallback_msg = "  Trying fallback pagination for this day..."
                    log_and_print(warn_msg, verbose, logger)
                    log_and_print(fallback_msg, verbose, logger)
                    
                    # Clear the day's issues and re-fetch with pagination
                    # Remove the issues we just added
                    all_issues = all_issues[:-len(day_issues)]
                    
                    # Use deprecated API with small batches for this problematic day
                    import warnings
                    with warnings.catch_warnings():
                        warnings.simplefilter("ignore")
                        batch_size = 25  # Very small batch size
                        start_at = 0
                        day_issues_paginated = []
                        
                        while True:
                            try:
                                batch = jira.search_issues(day_jql, startAt=start_at, maxResults=batch_size)
                                if len(batch) == 0:
                                    break
                                day_issues_paginated.extend(batch)
                                start_at += len(batch)
                                batch_msg = f"    Batch: retrieved {len(batch)} more issues (total for day: {len(day_issues_paginated)})"
                                log_and_print(batch_msg, verbose, logger)
                                
                                if len(batch) < batch_size:
                                    break
                            except Exception as batch_error:
                                print(f"    Batch failed: {batch_error}")
                                break
                        
                        fallback_result_msg = f"  Fallback pagination retrieved {len(day_issues_paginated)} issues for {day_str}"
                        log_and_print(fallback_result_msg, verbose, logger)
                        all_issues.extend(day_issues_paginated)
                
            except Exception as e:
                error_msg = f"  Day {day_str} failed: {e}"
                fallback_try_msg = f"  Trying fallback for {day_str}..."
                log_and_print(error_msg, verbose, logger)
                log_and_print(fallback_try_msg, verbose, logger)
                try:
                    import warnings
                    with warnings.catch_warnings():
                        warnings.simplefilter("ignore")
                        fallback_issues = jira.search_issues(day_jql, startAt=0, maxResults=100)
                        if len(fallback_issues) > 0:
                            print(f"    Fallback retrieved {len(fallback_issues)} issues for {day_str}")
                            all_issues.extend(fallback_issues)
                except Exception as fallback_error:
                    print(f"    Fallback also failed for {day_str}: {fallback_error}")
            
            # Move to next day
            current_date += timedelta(days=1)
            
            # Add a tiny delay to be respectful to the API
            import time
            time.sleep(0.1)
        
        if not verbose:
            print()  # New line after progress counter
        
        total_msg = f"Total issues retrieved across all days: {len(all_issues)}"
        log_and_print(total_msg, verbose, logger, force_print=True)
        
        # Remove any duplicates (shouldn't be any with daily chunks, but safety check)
        seen_keys = set()
        unique_issues = []
        for issue in all_issues:
            if issue.key not in seen_keys:
                seen_keys.add(issue.key)
                unique_issues.append(issue)
            else:
                dup_msg = f"  Removed duplicate: {issue.key}"
                log_and_print(dup_msg, verbose, logger)
        
        all_issues = unique_issues
        actual_count = len(all_issues)
        print(f"Final count after duplicate removal: {actual_count} unique issues")
        
        print("=" * 60)
        print("COMPARISON SUMMARY:")
        print("=" * 60)
        if 'expected_count' in locals():
            print(f"Expected count (enhanced_search_issues): {expected_count}")
        if 'api_total_count' in locals():
            print(f"Expected count (search_issues API):      {api_total_count}")
        print(f"Actual count (daily chunking):           {actual_count}")
        
        # Calculate differences
        if 'expected_count' in locals() and isinstance(expected_count, int):
            diff1 = actual_count - expected_count
            print(f"Difference from enhanced_search_issues:  {diff1:+d}")
        if 'api_total_count' in locals() and isinstance(api_total_count, int):
            diff2 = actual_count - api_total_count
            print(f"Difference from search_issues API:      {diff2:+d}")
        print("=" * 60)
        
        # NOW write the complete authoritative CSV with ALL issues
        print("Writing COMPLETE authoritative query results to CSV...")
        complete_issues_data = []
        for issue in all_issues:
            complete_issues_data.append({
                'key': issue.key,
                'created': getattr(issue.fields, 'created', ''),
                'updated': getattr(issue.fields, 'updated', ''),
                'status': getattr(issue.fields.status, 'name', '') if hasattr(issue.fields, 'status') else '',
                'issuetype': getattr(issue.fields.issuetype, 'name', '') if hasattr(issue.fields, 'issuetype') else ''
            })
        
        complete_df = pd.DataFrame(complete_issues_data)
        complete_csv_path = f"complete_count_query_results_{start_dt.strftime('%Y%m%d')}_{end_dt.strftime('%Y%m%d')}.csv"
        complete_df.to_csv(complete_csv_path, index=False)
        print(f"✅ COMPLETE Authoritative results written to: {complete_csv_path} ({len(all_issues)} issues)")
        print(f"Now proceeding to fetch individual issue histories...")
        
        # Write out debug file
        with open("issues.json", "w", encoding="utf-8") as f:
            issues_as_dicts = [issue.raw for issue in all_issues]
            json.dump(issues_as_dicts, f)

        # Return list of issue keys
        issue_keys = [issue.key for issue in all_issues]
        return issue_keys
        
    except Exception as e:
        print(f"Query failed: {e}")
        return []

# Chunking functions no longer needed - keeping for reference
def get_issues_by_chunks_OLD(jira, start_dt, end_dt, expected_total=None):
    """Get issues by breaking date range into smaller chunks with validation"""
    
    all_issues = []
    issue_keys_seen = set()  # Track unique issue keys to avoid duplicates
    current_start = start_dt
    chunk_days = 7  # Start with weekly chunks
    
    while current_start <= end_dt:
        current_end = min(current_start + timedelta(days=chunk_days), end_dt)
        
        chunk_start_str = current_start.strftime('%Y-%m-%d')
        chunk_end_str = current_end.strftime('%Y-%m-%d')
        
        jql = f"project = AEAREP AND createdDate>='{chunk_start_str}' AND createdDate<='{chunk_end_str}' AND issuetype = Task ORDER BY createdDate DESC"
        
        print(f"Fetching issues from {chunk_start_str} to {chunk_end_str}")
        
        try:
            chunk_issues = jira.enhanced_search_issues(jql)
            print(f"  Got {len(chunk_issues)} issues in this chunk")
            
            # Check for duplicates and add unique issues
            new_issues = []
            for issue in chunk_issues:
                if issue.key not in issue_keys_seen:
                    issue_keys_seen.add(issue.key)
                    new_issues.append(issue)
            
            if len(new_issues) != len(chunk_issues):
                print(f"  Filtered out {len(chunk_issues) - len(new_issues)} duplicate issues")
            
            all_issues.extend(new_issues)
            
            # If we get the maximum (50), the chunk might be too large
            if len(chunk_issues) >= 50:
                print(f"  Chunk may be truncated (got {len(chunk_issues)}), reducing chunk size")
                # Reduce chunk size and retry this period
                if chunk_days > 1:
                    chunk_days = max(1, chunk_days // 2)
                    continue
                else:
                    print(f"  Warning: Even daily chunks are hitting the 50-result limit")
            
            # If chunk was small, we can increase chunk size for efficiency
            if len(chunk_issues) < 10 and chunk_days < 30:
                chunk_days = min(30, chunk_days * 2)
                
        except Exception as e:
            print(f"  Failed to fetch chunk {chunk_start_str} to {chunk_end_str}: {e}")
            
        current_start = current_end + timedelta(days=1)
    
    # Validate against expected total if provided
    if expected_total is not None:
        actual_count = len(all_issues)
        if actual_count != expected_total:
            print(f"WARNING: Expected {expected_total} issues but got {actual_count}")
            print(f"This may indicate issues are being missed due to API limitations")
            
            # Save initial results to CSV for analysis
            initial_issues_data = []
            for issue in all_issues:
                initial_issues_data.append({
                    'key': issue.key,
                    'created': getattr(issue.fields, 'created', ''),
                    'updated': getattr(issue.fields, 'updated', ''),
                    'status': getattr(issue.fields.status, 'name', '') if hasattr(issue.fields, 'status') else '',
                    'issuetype': getattr(issue.fields.issuetype, 'name', '') if hasattr(issue.fields, 'issuetype') else ''
                })
            
            initial_df = pd.DataFrame(initial_issues_data)
            initial_csv_path = f"initial_search_results_{start_dt.strftime('%Y%m%d')}_{end_dt.strftime('%Y%m%d')}.csv"
            initial_df.to_csv(initial_csv_path, index=False)
            print(f"Initial search results saved to: {initial_csv_path}")
            
            # Try a more aggressive search if we're missing any issues
            if actual_count < expected_total:  # If missing any issues at all
                print("Attempting more comprehensive search...")
                # Try different ordering and search approaches
                additional_issues = get_missing_issues_OLD(jira, start_dt, end_dt, issue_keys_seen)
                
                # Save missed issues to CSV for analysis
                if additional_issues:
                    missed_issues_data = []
                    for issue in additional_issues:
                        missed_issues_data.append({
                            'key': issue.key,
                            'created': getattr(issue.fields, 'created', ''),
                            'updated': getattr(issue.fields, 'updated', ''),
                            'status': getattr(issue.fields.status, 'name', '') if hasattr(issue.fields, 'status') else '',
                            'issuetype': getattr(issue.fields.issuetype, 'name', '') if hasattr(issue.fields, 'issuetype') else ''
                        })
                    
                    missed_df = pd.DataFrame(missed_issues_data)
                    missed_csv_path = f"missed_issues_{start_dt.strftime('%Y%m%d')}_{end_dt.strftime('%Y%m%d')}.csv"
                    missed_df.to_csv(missed_csv_path, index=False)
                    print(f"Missed issues saved to: {missed_csv_path}")
                
                all_issues.extend(additional_issues)
                print(f"After comprehensive search: {len(all_issues)} total issues")
    
    return all_issues

def get_issues_daily_fallback_OLD(jira, start_dt, end_dt):
    """Fallback method using daily chunks when weekly chunks miss issues"""
    
    all_issues = []
    issue_keys_seen = set()
    current_date = start_dt
    
    while current_date <= end_dt:
        date_str = current_date.strftime('%Y-%m-%d')
        jql = f"project = AEAREP AND createdDate>='{date_str}' AND createdDate<='{date_str}' AND issuetype = Task ORDER BY createdDate DESC"
        
        try:
            daily_issues = jira.enhanced_search_issues(jql)
            print(f"  Daily fallback {date_str}: {len(daily_issues)} issues")
            
            # Add unique issues
            for issue in daily_issues:
                if issue.key not in issue_keys_seen:
                    issue_keys_seen.add(issue.key)
                    all_issues.append(issue)
            
            if len(daily_issues) >= 50:
                print(f"  WARNING: Daily limit hit on {date_str} - some issues may be missing")
                
        except Exception as e:
            print(f"  Daily fallback failed for {date_str}: {e}")
            
        current_date = current_date + timedelta(days=1)
    
    return all_issues

def get_missing_issues_OLD(jira, start_dt, end_dt, existing_keys):
    """Try alternative search strategies to find missing issues"""
    
    additional_issues = []
    start_str = start_dt.strftime('%Y-%m-%d')
    end_str = end_dt.strftime('%Y-%m-%d')
    
    print(f"  Searching for missing issues with alternative methods...")
    
    # Try different orderings that might reveal different issues
    alternative_queries = [
        f"project = AEAREP AND createdDate>='{start_str}' AND createdDate<='{end_str}' AND issuetype = Task ORDER BY key ASC",
        f"project = AEAREP AND createdDate>='{start_str}' AND createdDate<='{end_str}' AND issuetype = Task ORDER BY updated DESC",
        f"project = AEAREP AND createdDate>='{start_str}' AND createdDate<='{end_str}' AND issuetype = Task ORDER BY created ASC",
    ]
    
    for i, alt_jql in enumerate(alternative_queries):
        try:
            print(f"    Trying alternative query {i+1}...")
            alt_issues = jira.enhanced_search_issues(alt_jql)
            new_count = 0
            for issue in alt_issues:
                if issue.key not in existing_keys:
                    additional_issues.append(issue)
                    existing_keys.add(issue.key)
                    new_count += 1
            print(f"    Found {new_count} new issues with alternative query {i+1}")
        except Exception as e:
            print(f"    Alternative query {i+1} failed: {e}")
    
    return additional_issues

def get_issue_history(jira, issue_key, fields):
    """Get full changelog for issue"""

    # Start from the complete state of the JIRA ticket, then walk backwards in the 'changelog' when recording changes.

    issue = jira.issue(issue_key, expand='changelog')

    # Initialize state with most recent values
    state = {}
    for f in fields:
        if f in ['issue_key', 'As Of Date', 'Changed Fields']:
            continue  # Skip system fields, handle separately
        try:
            field_value = getattr(issue.fields, f, None)
            # Handle complex field types
            if field_value is not None and hasattr(field_value, '__dict__') and hasattr(field_value, 'name'):
                state[f] = field_value.name
            elif isinstance(field_value, list) and field_value and hasattr(field_value[0], 'name'):
                state[f] = ', '.join([item.name for item in field_value if item is not None])
            else:
                state[f] = field_value
        except Exception as e:
            print(f"Warning: Could not access field {f}: {e}")
            state[f] = None
    
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
    mcstatuses = getattr(issue.fields, 'customfield_10061', None)
    if mcstatuses is not None:
        # Check if mcstatuses is a list
        if isinstance(mcstatuses, list):
            # Handle different object types in the list
            formatted_statuses = []
            for mcstatus in mcstatuses:
                if mcstatus is None:
                    continue
                # Try to get the value attribute first, then fallback to string conversion
                if hasattr(mcstatus, 'value'):
                    formatted_statuses.append(mcstatus.value)
                elif hasattr(mcstatus, 'name'):
                    formatted_statuses.append(mcstatus.name)
                else:
                    formatted_statuses.append(str(mcstatus))
            mcstatuses = ', '.join(formatted_statuses)
        else:
            # If mcstatuses is not a list, handle single value
            if hasattr(mcstatuses, 'value'):
                mcstatuses = mcstatuses.value
            elif hasattr(mcstatuses, 'name'):
                mcstatuses = mcstatuses.name
            else:
                mcstatuses = str(mcstatuses)
    else:
        mcstatuses = ''
    # Initialize the 'MCStatus' field with the new string
    state['customfield_10061'] = mcstatuses

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

    changed_fields_list = []

    # Iterate over the histories
    for i, history in enumerate(histories):

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
            # Handle both old and new API response formats
            from_value = getattr(item, 'fromString', getattr(item, 'from', None))
            to_value = getattr(item, 'toString', getattr(item, 'to', None))
            
            # Handle callable toString vs string property
            if callable(to_value):
                to_value = to_value()
            if callable(from_value):
                from_value = from_value()
                
            if from_value != to_value:
                changed_fields.append(item.field)

                # If the field is not in new_state, add it
                if item.field not in new_state:
                    new_state[item.field] = None
                
                new_state[item.field] = from_value
                
        # Store the 'Changed Fields' for this history
        changed_fields_list.append(changed_fields)

        # After updating the state based on the items of a history, append a copy of the state to all_states
        all_states.append(new_state.copy())

        # If this is not the first history, add the 'Changed Fields' to the previous state
        if i > 0:
            all_states[-2]['Changed Fields'] = ', '.join(changed_fields_list[-1])

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
    parser.add_argument("-f", "--fieldfile", required=False, default="jira-fields.csv", help="CSV file with fields to extract")
    parser.add_argument("-o", "--outfile", required=False, default="issue_history.csv", help="Output file. Date will be appended to the filename.")
    parser.add_argument("--verbose", action="store_true", help="Display detailed progress information on terminal (also logged to file)")

    args = parser.parse_args()

    start_date = args.start 
    end_date = args.end
    jiradomain = args.domain
    fieldfile = args.fieldfile
    verbose = args.verbose
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
    
    # Create logs directory
    logdir = os.path.join(get_rootdir(), "logs")
    if not os.path.exists(logdir):
        os.makedirs(logdir)
    
    # Setup logging
    log_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_filename = os.path.join(logdir, f"jira_download_{start_date}_{end_date}_{log_timestamp}.log")
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(message)s',
        handlers=[
            logging.FileHandler(log_filename),
        ]
    )
    logger = logging.getLogger(__name__)

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

    # we get the fields from the excel file
    fields, id_to_name, names = get_fields(fieldfile)

    # Initialize JIRA connection with v3 API
    jira = JIRA(server=jiradomain, basic_auth=(jira_username(), get_api_key()))

    issue_keys = get_issues(jira, start_date, end_date, verbose, logger)

    all_states = []
    
    log_and_print(f"Starting individual history fetch for {len(issue_keys)} issues", verbose, logger, force_print=True)
    total_issues = len(issue_keys)
    
    for i, key in enumerate(issue_keys, 1):
        progress_msg = f"Fetching history for {key} ({i}/{total_issues})"
        if not verbose:
            print(f"\r{progress_msg}", end="", flush=True)
        log_and_print(progress_msg, verbose, logger)
        histories = get_issue_history(jira, key,fields)
        all_states.append(histories)
    
    if not verbose:
        print()  # New line after progress counter
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
