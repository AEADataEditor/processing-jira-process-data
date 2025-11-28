# JIRA v3 API Migration

This document describes the migration of the JIRA scripts from v2 to v3 API.

## Changes Made

### Environment Setup
- **Python Version**: Updated to require Python 3.6+ (for f-string support)
- **Virtual Environment**: Configured Python 3.10 environment in `processing/` directory
- **Dependencies**: Updated `requirements.txt` to specify `jira>=3.8.0`

### API Updates

#### Connection Changes
- **Old**: `JIRA(options, basic_auth=(username, api_token))` with options dict
- **New**: `JIRA(server=jiradomain, basic_auth=(username, api_token))` direct parameters

#### Field Access Improvements
- Enhanced field value extraction to handle different object types
- Added proper null checking and error handling
- Improved handling of complex field types (custom fields, lists, etc.)

#### Changelog Processing
- Fixed `toString()` vs `toString` property access
- Added fallback for both old and new API response formats
- Enhanced error handling for field access

#### Search API Updates
- **Old**: `search_issues(jql, start, batch_size)`
- **New**: `search_issues(jql, startAt=start, maxResults=batch_size)`

### Files Updated

1. **`00_get_fields.py`**: Field catalog extraction script
2. **`01_download_issues.py`**: Issue history extraction script
3. **`requirements.txt`**: Updated dependencies
4. **`programs/run_python.sh`**: Convenience script for running Python with correct environment
5. **`programs/test_jira_v3.py`**: Test script to verify JIRA v3 API connectivity

## Usage

### Setup
1. Configure environment variables:
   ```bash
   export JIRA_USERNAME="your_username"
   export JIRA_API_KEY="your_api_key"
   ```

2. Or create a `.env` file in the project root:
   ```
   JIRA_USERNAME=your_username
   JIRA_API_KEY=your_api_key
   ```

### Running Scripts

#### Using the convenience script:
```bash
cd programs/
./run_python.sh 00_get_fields.py --help
./run_python.sh 01_download_issues.py --help
```

#### Direct execution:
```bash
# From project root
processing/bin/python programs/00_get_fields.py --help
processing/bin/python programs/01_download_issues.py --help
```

### Testing
```bash
cd programs/
./run_python.sh test_jira_v3.py
```

## Compatibility

The output format remains compatible with previous versions to ensure existing R scripts continue to work without modification. The key compatibility features:

- Same CSV structure and field names
- Consistent date formatting
- Preserved custom field handling (MCStatus, etc.)
- Same file naming conventions

## Field Processing Improvements

### Custom Field Handling
- **MCStatus (customfield_10061)**: Enhanced to handle different object types and extract proper values
- **Subtasks**: Improved filtering and formatting
- **Complex objects**: Added proper attribute extraction (name, value properties)

### Error Handling
- Graceful handling of missing fields
- Improved error messages for debugging
- Fallback mechanisms for API response variations

## Migration Notes

The scripts have been tested to maintain backward compatibility while leveraging the improved stability and features of the JIRA v3 API. The main benefits include:

1. **Better Performance**: v3 API is more efficient
2. **Enhanced Stability**: Improved error handling and retry mechanisms  
3. **Future-Proof**: v2 API is deprecated and will be removed
4. **Better Field Access**: More reliable field value extraction

All existing workflows should continue to work without modification.