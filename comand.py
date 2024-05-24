import subprocess

try:
    # This splits the command into parts: the utility, options, and the specific device identifier
    result = subprocess.run(['iio_attr', '-u', 'local:', '-C'], capture_output=True, text=True, check=True)
    print("Output from iio_attr for device 'cf-ad9361-lpc':")
    print(result.stdout)
except subprocess.CalledProcessError as e:
    print("iio_attr command failed. Ensure that libiio is installed and configured correctly.")
    print("Error message:", e.stderr)
