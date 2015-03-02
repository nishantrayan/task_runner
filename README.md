TaskRunner
Inputs:
 * List of machines
 * Path to private key
 * Path to script to execute (it should take input item, output directory, log file as inputs)
 * Input file (one line per input item)
 * Marker directory
 * Output directory
 * Log file path


 Steps
 1. Find a master node and deploy the script there.
 2. Start the script with the above mentioned inputs
 3. Screen session should start automatically and start logging the progress

 Script's works as follows,
 1. Split the input into reasonable sized chunks
 2. Creates a map of files to be uploaded to the servers
 3. Uploads the files to all the servers
 4. In each of the machines it starts a screen session
 5. Runs the script in the screen session passing one line of input at a time.
 6. Logs the marker (line number) in a marker directory
 7. Cats the log file and assembles them in the master node's log file.
