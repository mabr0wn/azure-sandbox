Here's a simple Python script to test a Bicep file using the Azure CLI and Python's `subprocess` module. This script will validate the Bicep file to ensure that it has no syntax errors and can be successfully compiled to an ARM template.

### `test_bicep.py`

```python
import subprocess
import os

def validate_bicep(bicep_file):
    """
    Validate the Bicep file using the Azure CLI.
    
    Args:
        bicep_file (str): The path to the Bicep file to validate.
        
    Returns:
        bool: True if the Bicep file is valid, False otherwise.
    """
    try:
        # Run Azure CLI command to validate the Bicep file
        result = subprocess.run(['az', 'bicep', 'build', '--file', bicep_file], 
                                capture_output=True, text=True, check=True)
        print("Bicep file validation successful.")
        return True
    except subprocess.CalledProcessError as e:
        print("Bicep file validation failed.")
        print(e.stderr)
        return False

def main():
    # Set the path to your Bicep file
    bicep_file = os.path.join(os.getcwd(), 'main.bicep')
    
    # Validate the Bicep file
    if validate_bicep(bicep_file):
        print("Bicep file is valid.")
    else:
        print("Bicep file is invalid.")

if __name__ == "__main__":
    main()
```

### Explanation:
- **validate_bicep(bicep_file)**: This function runs the Azure CLI command `az bicep build --file <bicep_file>` to validate the Bicep file. If the validation is successful, it returns `True`; otherwise, it returns `False`.
- **main()**: The main function sets the path to your Bicep file (`main.bicep` in this example) and calls the `validate_bicep()` function to check its validity.

### How to Run:
1. Ensure you have the Azure CLI installed and logged in.
2. Place this script in the same directory as your Bicep file (`main.bicep`).
3. Run the script using Python:

```bash
python test_bicep.py
```
TEST
The script will output whether the Bicep file is valid or if there are any issues that need to be addressed.