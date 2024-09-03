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