using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.NetworkInformation;
using System.Threading;
using System.Windows;
using System.Xml.Linq;

namespace BH4SFv._1._1
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }


        // declare variables for client detials strings
        static string clientName;
        static string externalID;
        static string instanceName;
        static string username;
        static string password;
        static string token;
        static string name;
        static string notes;

        static string candidateQuery;
        static string contactQuery;
        static string placementQuery;
        static string submissionQuery;
        static string companyQuery;
        static string jobQuery;

        static string pathInitial;
        static string pathHourly;
        static string pathBin; 
        static string pathLogs;
        static string pathCredsFile;
        static string pathActivityLog;

        static string intialSyncFolder = "Initial";
        static string hourlySyncFolder = "Hourly";
        static string binFolder = "Bin";
        static string infoSyncFolder = "Logs&Info";
        static string salesForceFolder = @"C:\Users\chris\Desktop\SalesForce Clients";

        static string standardWhereClause = "WHERE(LastModifiedDate = LAST_N_DAYS:1 OR LastModifiedDate = TODAY OR CreatedDate = LAST_N_DAYS:1 OR CreatedDate = TODAY)";


        //event handler fo button click - kicks off whooe process
        private void syncButton_Click(object sender, RoutedEventArgs e)
        {
            //error checking for empty cleit name texbox
            if (clientNameTextBox.Text.Length == 0)
            {
                MessageBox.Show("'Client name...' (under Credentials) cannot be empty. This is used to generate a directory for the files to go in, so there needs to be something written here.", "Hangabout...", MessageBoxButton.OK);
            }
            else
            {
                //assign variables to textbox content
                clientName = clientNameTextBox.Text;
                externalID = externalIDTextbox.Text;
                instanceName = instanceNameTextBox.Text;
                username = usernameTextBox.Text;
                password = passwordTextBox.Text;
                token = tokenTextBox.Text;

                name = nameTextBox.Text;
                notes = notesTextBox.Text;


                //assign path strings to duynamic info added in textboxes
                pathInitial = salesForceFolder + "\\" + clientName + "\\" + intialSyncFolder;
                pathHourly = salesForceFolder + "\\" + clientName + "\\" + hourlySyncFolder;
                pathBin = salesForceFolder + "\\" + clientName + "\\" + binFolder;
                pathLogs = salesForceFolder + "\\" + clientName + "\\" + infoSyncFolder;
                pathCredsFile = salesForceFolder + "\\" + clientName + "\\" + infoSyncFolder + "\\" + clientName + " Credentials " + DateTime.Now.ToString("MM-dd-yyyy-h-mm-tt") + ".txt";
                pathActivityLog = salesForceFolder + "\\" + clientName + "\\" + infoSyncFolder + "\\" + clientName + " Activity Log.txt";
                

                CreateFolders();
                CreateCredentialsFile();

                CandidateCreateSDLFiles();
                ContactCreateSDLFiles();
                PlacementCreateSDLFiles();
                SubmissionCreateSDLFiles();
                CompanyCreateSDLFiles();
                JobCreateSDLFiles();

                CreateProcessConfigFiles();

                CreateHerefishProcessBatFile();

                MessageBox.Show("All files created & Initial Import underway. Your files for "+clientName+" are availble at " + salesForceFolder, "All Done!");



            }



        }


        // method to create folders
        private void CreateFolders()
        {
            // If initial directory does not exist, create it
            if (!Directory.Exists(pathInitial))
            {
                Directory.CreateDirectory(pathInitial);
            }

            // if hourly directory does not exist, create it
            if (!Directory.Exists(pathHourly))
            {
                Directory.CreateDirectory(pathHourly);
            }

            // if logs & info directory does not exist, create it
            if (!Directory.Exists(pathLogs))
            {
                Directory.CreateDirectory(pathLogs);
            }

            // if Bin directory does not exist, create it
            if (!Directory.Exists(pathBin))
            {
                Directory.CreateDirectory(pathBin);
            }

            using (StreamWriter ActivityFile = File.CreateText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - Initial & Hourly directories created by "+name+" - Notes: "+notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - Logs & Info folders created by "+name+" - Notes: "+notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - Bin folder created by "+name+" - Notes: "+notes);
            }
        }



        //method to create credentials file
        private void CreateCredentialsFile()
        {
            // Create a new file     
            using (StreamWriter CredsFile = File.CreateText(pathCredsFile))
            {
                CredsFile.WriteLine("New file created: {0}", DateTime.Now.ToString());
                CredsFile.WriteLine("Cient Name: " + clientName);
                CredsFile.WriteLine("External ID: " + externalID);
                CredsFile.WriteLine("Instance Name: " + instanceName);
                CredsFile.WriteLine("Username: " + username);
                CredsFile.WriteLine("Password: " + password);
                CredsFile.WriteLine("Token: " + token);
            }

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - Credentials File created by " + name + " - Notes: " + notes);
            }
        }



        //sdl writing methods
        public void CandidateCreateSDLFiles()
        {

            //set entity
            string entity = "Candidate";
            // assign queryboxes to strings
            string queryString = candidateQueryTextBox.Text;

            //designate the path where the SDL file will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + entity + "ExtractMap.sdl";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + entity + "ExtractMap.sdl";



            // Character to remove "FROM"
            int index = queryString.LastIndexOf(" FROM ");

            if (index > 0)
                queryString = queryString.Substring(0, index); // This will remove all text after character FROM


            //create array of whitespaces and delimiters to be removed from the query
            string[] Queryseparator = { " ", ",", ";" };

            //separate 1 query string into individual fields
            string[] splitFields = queryString.Split(Queryseparator, StringSplitOptions.RemoveEmptyEntries);

            //create a list from the array that we can then manipulate
            List<string> listOfSplitFields = new List<string>(splitFields);



            //sorts the list into alphabetical order
            listOfSplitFields.Sort();

            //removes non-field strings form the query
            //listOfSplitFields.Remove("Candidates:");
            listOfSplitFields.Remove("SELECT");
            listOfSplitFields.Remove("FROM");
            listOfSplitFields.Remove(entity + "s:");


            //initialise a list for the "field=field" format to be written to sdl file
            List<string> listOfFormattedFields = new List<string>();



            //add each field in the "field=field" format to the new list
            foreach (var i in listOfSplitFields)
            {
                // Console.WriteLine(i + "=" + i);
                listOfFormattedFields.Add(i + "=" + i);
            }


            //print that new fomatted list into a text file in initial folder
            File.WriteAllLines(initialPath, listOfFormattedFields);
            //print that new fomatted list into a text file in hourly folder
            File.WriteAllLines(hourlyPath, listOfFormattedFields);

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Initial SDL Files created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Hourly SDL Files created by " + name + " - Notes: " + notes);
            }


        }
        public void ContactCreateSDLFiles()
        {
            //set entity
            string entity = "Contact";
            // assign queryboxes to strings
            string queryString = contactQueryTextBox.Text;

            //designate the path where the SDL file will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + entity + "ExtractMap.sdl";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + entity + "ExtractMap.sdl";






            // Character to remove "FROM"
            int index = queryString.LastIndexOf(" FROM ");

            if (index > 0)
                queryString = queryString.Substring(0, index); // This will remove all text after character FROM


            //create array of whitespaces and delimiters to be removed from the query
            string[] Queryseparator = { " ", ",", ";" };

            //separate 1 query string into individual fields
            string[] splitFields = queryString.Split(Queryseparator, StringSplitOptions.RemoveEmptyEntries);

            //create a list from the array that we can then manipulate
            List<string> listOfSplitFields = new List<string>(splitFields);



            //sorts the list into alphabetical order
            listOfSplitFields.Sort();

            //removes non-field strings form the query
            //listOfSplitFields.Remove("Candidates:");
            listOfSplitFields.Remove("SELECT");
            listOfSplitFields.Remove("FROM");
            listOfSplitFields.Remove(entity + "s:");


            //initialise a list for the "field=field" format to be written to sdl file
            List<string> listOfFormattedFields = new List<string>();



            //add each field in the "field=field" format to the new list
            foreach (var i in listOfSplitFields)
            {
                // Console.WriteLine(i + "=" + i);
                listOfFormattedFields.Add(i + "=" + i);
            }


            //print that new fomatted list into a text file in initial folder
            File.WriteAllLines(initialPath, listOfFormattedFields);
            //print that new fomatted list into a text file in hourly folder
            File.WriteAllLines(hourlyPath, listOfFormattedFields);

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Initial SDL Files created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Hourly SDL Files created by " + name + " - Notes: " + notes);
            }


        }
        public void PlacementCreateSDLFiles()
        {
            //set entity
            string entity = "Placement";
            // assign queryboxes to strings
            string queryString = placementQueryTextBox.Text;

            //designate the path where the SDL file will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + entity + "ExtractMap.sdl";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + entity + "ExtractMap.sdl";






            // Character to remove "FROM"
            int index = queryString.LastIndexOf(" FROM ");

            if (index > 0)
                queryString = queryString.Substring(0, index); // This will remove all text after character FROM


            //create array of whitespaces and delimiters to be removed from the query
            string[] Queryseparator = { " ", ",", ";" };

            //separate 1 query string into individual fields
            string[] splitFields = queryString.Split(Queryseparator, StringSplitOptions.RemoveEmptyEntries);

            //create a list from the array that we can then manipulate
            List<string> listOfSplitFields = new List<string>(splitFields);



            //sorts the list into alphabetical order
            listOfSplitFields.Sort();

            //removes non-field strings form the query
            //listOfSplitFields.Remove("Candidates:");
            listOfSplitFields.Remove("SELECT");
            listOfSplitFields.Remove("FROM");
            listOfSplitFields.Remove(entity + "s:");


            //initialise a list for the "field=field" format to be written to sdl file
            List<string> listOfFormattedFields = new List<string>();



            //add each field in the "field=field" format to the new list
            foreach (var i in listOfSplitFields)
            {
                // Console.WriteLine(i + "=" + i);
                listOfFormattedFields.Add(i + "=" + i);
            }


            //print that new fomatted list into a text file in initial folder
            File.WriteAllLines(initialPath, listOfFormattedFields);
            //print that new fomatted list into a text file in hourly folder
            File.WriteAllLines(hourlyPath, listOfFormattedFields);

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Initial SDL Files created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Hourly SDL Files created by " + name + " - Notes: " + notes);
            }


        }
        public void SubmissionCreateSDLFiles()
        {
            //set entity
            string entity = "Submission";
            // assign queryboxes to strings
            string queryString = submissionQueryTextBox.Text;

            //designate the path where the SDL file will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + entity + "ExtractMap.sdl";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + entity + "ExtractMap.sdl";






            // Character to remove "FROM"
            int index = queryString.LastIndexOf(" FROM ");

            if (index > 0)
                queryString = queryString.Substring(0, index); // This will remove all text after character FROM


            //create array of whitespaces and delimiters to be removed from the query
            string[] Queryseparator = { " ", ",", ";" };

            //separate 1 query string into individual fields
            string[] splitFields = queryString.Split(Queryseparator, StringSplitOptions.RemoveEmptyEntries);

            //create a list from the array that we can then manipulate
            List<string> listOfSplitFields = new List<string>(splitFields);



            //sorts the list into alphabetical order
            listOfSplitFields.Sort();

            //removes non-field strings form the query
            //listOfSplitFields.Remove("Candidates:");
            listOfSplitFields.Remove("SELECT");
            listOfSplitFields.Remove("FROM");
            listOfSplitFields.Remove(entity + ":");


            //initialise a list for the "field=field" format to be written to sdl file
            List<string> listOfFormattedFields = new List<string>();



            //add each field in the "field=field" format to the new list
            foreach (var i in listOfSplitFields)
            {
                // Console.WriteLine(i + "=" + i);
                listOfFormattedFields.Add(i + "=" + i);
            }


            //print that new fomatted list into a text file in initial folder
            File.WriteAllLines(initialPath, listOfFormattedFields);
            //print that new fomatted list into a text file in hourly folder
            File.WriteAllLines(hourlyPath, listOfFormattedFields);

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Initial SDL Files created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Hourly SDL Files created by " + name + " - Notes: " + notes);
            }


        }
        public void CompanyCreateSDLFiles()
        {
            //set entity
            string entity = "Company";
            // assign queryboxes to strings
            string queryString = companyQueryTextBox.Text;

            //designate the path where the SDL file will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + entity + "ExtractMap.sdl";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + entity + "ExtractMap.sdl";






            // Character to remove "FROM"
            int index = queryString.LastIndexOf(" FROM ");

            if (index > 0)
                queryString = queryString.Substring(0, index); // This will remove all text after character FROM


            //create array of whitespaces and delimiters to be removed from the query
            string[] Queryseparator = { " ", ",", ";" };

            //separate 1 query string into individual fields
            string[] splitFields = queryString.Split(Queryseparator, StringSplitOptions.RemoveEmptyEntries);

            //create a list from the array that we can then manipulate
            List<string> listOfSplitFields = new List<string>(splitFields);



            //sorts the list into alphabetical order
            listOfSplitFields.Sort();

            //removes non-field strings form the query
            //listOfSplitFields.Remove("Candidates:");
            listOfSplitFields.Remove("SELECT");
            listOfSplitFields.Remove("FROM");
            listOfSplitFields.Remove(entity + ":");


            //initialise a list for the "field=field" format to be written to sdl file
            List<string> listOfFormattedFields = new List<string>();



            //add each field in the "field=field" format to the new list
            foreach (var i in listOfSplitFields)
            {
                // Console.WriteLine(i + "=" + i);
                listOfFormattedFields.Add(i + "=" + i);
            }


            //print that new fomatted list into a text file in initial folder
            File.WriteAllLines(initialPath, listOfFormattedFields);
            //print that new fomatted list into a text file in hourly folder
            File.WriteAllLines(hourlyPath, listOfFormattedFields);

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Initial SDL Files created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Hourly SDL Files created by " + name + " - Notes: " + notes);
            }


        }
        public void JobCreateSDLFiles()
        {
            //set entity
            string entity = "Job";
            // assign queryboxes to strings
            string queryString = jobQueryTextBox.Text;

            //designate the path where the SDL file will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + entity + "ExtractMap.sdl";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + entity + "ExtractMap.sdl";






            // Character to remove "FROM"
            int index = queryString.LastIndexOf(" FROM ");

            if (index > 0)
                queryString = queryString.Substring(0, index); // This will remove all text after character FROM


            //create array of whitespaces and delimiters to be removed from the query
            string[] Queryseparator = { " ", ",", ";" };

            //separate 1 query string into individual fields
            string[] splitFields = queryString.Split(Queryseparator, StringSplitOptions.RemoveEmptyEntries);

            //create a list from the array that we can then manipulate
            List<string> listOfSplitFields = new List<string>(splitFields);



            //sorts the list into alphabetical order
            listOfSplitFields.Sort();

            //removes non-field strings form the query
            //listOfSplitFields.Remove("Candidates:");
            listOfSplitFields.Remove("SELECT");
            listOfSplitFields.Remove("FROM");
            listOfSplitFields.Remove(entity + ":");


            //initialise a list for the "field=field" format to be written to sdl file
            List<string> listOfFormattedFields = new List<string>();



            //add each field in the "field=field" format to the new list
            foreach (var i in listOfSplitFields)
            {
                // Console.WriteLine(i + "=" + i);
                listOfFormattedFields.Add(i + "=" + i);
            }


            //print that new fomatted list into a text file in initial folder
            File.WriteAllLines(initialPath, listOfFormattedFields);
            //print that new fomatted list into a text file in hourly folder
            File.WriteAllLines(hourlyPath, listOfFormattedFields);

            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Initial SDL Files created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - " + entity + " - Hourly SDL Files created by " + name + " - Notes: " + notes);
            }


        }


        //create pricess cofig methods
        public void CreateProcessConfigFiles()
        {
            //INITIAL IMPORTS

            //asign query variables to input textbox strings
            candidateQuery = candidateQueryTextBox.Text;
            contactQuery = contactQueryTextBox.Text;
            placementQuery = placementQueryTextBox.Text;
            submissionQuery = submissionQueryTextBox.Text;
            companyQuery = companyQueryTextBox.Text;
            jobQuery = jobQueryTextBox.Text;

            //declare strings to be assigned with queries minus the entity suffex 
            string candidateQueryTrimmed;
            string contactQueryTrimmed;
            string placementQueryTrimmed;
            string submissionQueryTrimmed;
            string companyQueryTrimmed;
            string jobQueryTrimmed;


            //remove entity name form front of query if input textbox is not empty, if it is, set the string to ""
            if (candidateQueryTextBox.Text.Length != 0)
            {
                candidateQueryTrimmed = candidateQuery.Remove(0, 12);
            }
            else
            {
                candidateQueryTrimmed = "";
            }


            if (contactQueryTextBox.Text.Length != 0)
            {
                contactQueryTrimmed = contactQuery.Remove(0, 10);
            }
            else
            {
                contactQueryTrimmed = "";
            }


            if (placementQueryTextBox.Text.Length != 0)
            {
                placementQueryTrimmed = placementQuery.Remove(0, 12);
            }
            else
            {
                placementQueryTrimmed = "";
            }


            if (submissionQueryTextBox.Text.Length != 0)
            {
                submissionQueryTrimmed = submissionQuery.Remove(0, 12);
            }
            else
            {
                submissionQueryTrimmed = "";
            }


            if (companyQueryTextBox.Text.Length != 0)
            {
                companyQueryTrimmed = companyQuery.Remove(0, 9);
            }
            else
            {
                companyQueryTrimmed = "";
            }


            if (jobQueryTextBox.Text.Length != 0)
            {
                jobQueryTrimmed = jobQuery.Remove(0, 5);
            }
            else
            {
                jobQueryTrimmed = "";
            }


            // load the file using;
            var initialImportXML = XDocument.Load(@"C:\Users\chris\source\repos\BH4SFv.1.1\InitialProcessConfig.xml");

            // convert the xml into string
            string initialImport = initialImportXML.ToString();
           


            //replaces placeholders with textbox input in initial import process config
            string updatedInitial_1 = initialImport.Replace("TEMPLATE_INSTANCENAME", instanceName);
            string updatedInitial_2 = updatedInitial_1.Replace("TEMPLATE_USERNAME", username);
            string updatedInitial_3 = updatedInitial_2.Replace("TEMPLATE_PASSWORD", password);
            string updatedInitial_4 = updatedInitial_3.Replace("TEMPLATE_CANDIDATE_QUERY", candidateQueryTrimmed);
            string updatedInitial_5 = updatedInitial_4.Replace("TEMPLATE_CONTACT_QUERY", contactQueryTrimmed);
            string updatedInitial_6 = updatedInitial_5.Replace("TEMPLATE_PLACEMENT_QUERY", placementQueryTrimmed);
            string updatedInitial_7 = updatedInitial_6.Replace("TEMPLATE_SUBMISSION_QUERY", submissionQueryTrimmed);
            string updatedInitial_8 = updatedInitial_7.Replace("TEMPLATE_COMPANY_QUERY", companyQueryTrimmed);
            string updatedInitial_9 = updatedInitial_8.Replace("TEMPLATE_JOB_QUERY", jobQueryTrimmed);




            //HOURLY IMPORTS

            //declare strings to be assigned with queries minus the entity suffex 
            string candidateWhereClause;
            string contactWhereClause;
            string placementWhereClause;
            string submissionWhereClause;
            string companyWhereClause;
            string jobWhereClause;

            //check if there is a custom whereclause asigned, if not use the satdard one
            if (candidateWhereClauseTextBox.Text.Length == 0)
            {
                candidateWhereClause = standardWhereClause;
            }
            else
            {
                candidateWhereClause = candidateWhereClauseTextBox.Text;
            }


            if (contactWhereClauseTextBox.Text.Length == 0)
            {
                contactWhereClause = standardWhereClause;
            }
            else
            {
                contactWhereClause = contactWhereClauseTextBox.Text;
            }


            if (placementWhereClauseTextBox.Text.Length == 0)
            {
                placementWhereClause = standardWhereClause;
            }
            else
            {
                placementWhereClause = placementWhereClauseTextBox.Text;
            }


            if (submissionWhereClauseTextBox.Text.Length == 0)
            {
                submissionWhereClause = standardWhereClause;
            }
            else
            {
                submissionWhereClause = submissionWhereClauseTextBox.Text;
            }


            if (companyWhereClauseTextBox.Text.Length == 0)
            {
                companyWhereClause = standardWhereClause;
            }
            else
            {
                companyWhereClause = companyWhereClauseTextBox.Text;
            }


            if (jobWhereClauseTextBox.Text.Length == 0)
            {
                jobWhereClause = standardWhereClause;
            }
            else
            {
                jobWhereClause = jobWhereClauseTextBox.Text;
            }




            // load the file using;
            var hourlyImportXML = XDocument.Load(@"C:\Users\chris\source\repos\BH4SFv.1.1\HourlyProcessConfig.xml");

            // convert the xml into string
            string hourlyImport = hourlyImportXML.ToString();

            //replaces placeholders with textbox input in initial import process config
            string updatedHourly_1 = hourlyImport.Replace("TEMPLATE_INSTANCENAME", instanceName);
            string updatedHourly_2 = updatedHourly_1.Replace("TEMPLATE_USERNAME", username);
            string updatedHourly_3 = updatedHourly_2.Replace("TEMPLATE_PASSWORD", password);

            string updatedHourly_4 = updatedHourly_3.Replace("TEMPLATE_CANDIDATE_QUERY", candidateQueryTrimmed);
            string updatedHourly_5 = updatedHourly_4.Replace("TEMPLATE_CANDIDATE_WHERE", candidateWhereClause);

            string updatedHourly_6 = updatedHourly_5.Replace("TEMPLATE_CONTACT_QUERY", contactQueryTrimmed);
            string updatedHourly_7 = updatedHourly_6.Replace("TEMPLATE_CONTACT_WHERE", contactWhereClause);

            string updatedHourly_8 = updatedHourly_7.Replace("TEMPLATE_PLACEMENT_QUERY", placementQueryTrimmed);
            string updatedHourly_9 = updatedHourly_8.Replace("TEMPLATE_PLACEMENT_WHERE", placementWhereClause);

            string updatedHourly_10 = updatedHourly_9.Replace("TEMPLATE_SUBMISSION_QUERY", submissionQueryTrimmed);
            string updatedHourly_11 = updatedHourly_10.Replace("TEMPLATE_SUBMISSION_WHERE", submissionWhereClause);

            string updatedHourly_12 = updatedHourly_11.Replace("TEMPLATE_COMPANY_QUERY", companyQueryTrimmed);
            string updatedHourly_13 = updatedHourly_12.Replace("TEMPLATE_COMPANY_WHERE", companyWhereClause);

            string updatedHourly_14 = updatedHourly_13.Replace("TEMPLATE_JOB_QUERY", jobQueryTrimmed);
            string updatedHourly_15 = updatedHourly_14.Replace("TEMPLATE_JOB_WHERE", jobWhereClause);




            string[] InitialImportProcessConfig = { updatedInitial_9 };
            string[] HourlyImportProcessConfig = { updatedHourly_15 };

            Thread.Sleep(500);


            //designate the path where the process config files will be created
            string initialPath = salesForceFolder + "\\" + clientName + "\\" + "Initial" + "\\" + "process-config.xml";
            string hourlyPath = salesForceFolder + "\\" + clientName + "\\" + "Hourly" + "\\" + "process-config.xml";

            // Create a new file     
            File.WriteAllLines(initialPath, InitialImportProcessConfig);
            File.WriteAllLines(hourlyPath, HourlyImportProcessConfig);


            //update activity log
            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - Initial process-config file created by " + name + " - Notes: " + notes);
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - Hourly process-config file created by " + name + " - Notes: " + notes);
            }


        }


        //method to create herefish_process.bat file
        public void CreateHerefishProcessBatFile()
        {

            //preapres the template that willl be inserted into bat file depending on whether or not the entity is being loaded

            //candidate entity
            string candidateBatString;

            string candidateBatON = "call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvCandidateExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_candidate%\"";
            string candidateBatOFF = "::call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvCandidateExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_candidate%\"";

            if (candidateQueryTextBox.Text.Length != 0)
            {
                candidateBatString = candidateBatON;
            }
            else
            {
                candidateBatString = candidateBatOFF;
            }


            //contact entity
            string contactBatString;

            string contactBatON = "call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvContactExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_contact%\"";
            string contactBatOFF = "::call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvContactExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_contact%\"";

            if (contactQueryTextBox.Text.Length != 0)
            {
                contactBatString = contactBatON;
            }
            else
            {
                contactBatString = contactBatOFF;
            }


            //placement entity
            string placementBatString;

            string placementBatON = "call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvPlacementExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_placement%\"";
            string placementBatOFF = "::call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvPlacementExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_placement%\"";

            if (placementQueryTextBox.Text.Length != 0)
            {
                placementBatString = placementBatON;
            }
            else
            {
                placementBatString = placementBatOFF;
            }



            //submission entity
            string submissionBatString;

            string submissionBatON = "call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvApplicationExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_application%\"";
            string submissionBatOFF = "::call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvApplicationExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_application%\"";

            if (submissionQueryTextBox.Text.Length != 0)
            {
                submissionBatString = submissionBatON;
            }
            else
            {
                submissionBatString = submissionBatOFF;
            }



            //company entity
            string companyBatString;

            string companyBatON = "call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvAccountExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_account%\"";
            string companyBatOFF = "::call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvAccountExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_account%\"";

            if (companyQueryTextBox.Text.Length != 0)
            {
                companyBatString = companyBatON;
            }
            else
            {
                companyBatString = companyBatOFF;
            }



            //job entity
            string jobBatString;

            string jobBatON = "call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvJobExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_job%\"";
            string jobBatOFF = "::call dataloader_win\\bin\\process.bat C:\\Initial_Import\\dataloader_win\\ csvJobExtractProcess  \"dataAccess.name=C:\\Initial_Import\\dataloader_win\\export\\%export_job%\"";

            if (jobQueryTextBox.Text.Length != 0)
            {
                jobBatString = jobBatON;
            }
            else
            {
                jobBatString = jobBatOFF;
            }



      
            // load the bat file using;
            string batFile = File.ReadAllText(@"C:\Users\chris\source\repos\BH4SFv.1.1\herefish_process.txt");

            //replaces placeholders with textbox input in initial import process config
            string updatedBAT_1 = batFile.Replace("TEMPLATE_CANDIDATE_BAT", candidateBatString);
            string updatedBAT_2 = updatedBAT_1.Replace("TEMPLATE_CONTACT_BAT", contactBatString);
            string updatedBAT_3 = updatedBAT_2.Replace("TEMPLATE_PLACEMENT_BAT", placementBatString);
            string updatedBAT_4 = updatedBAT_3.Replace("TEMPLATE_SUBMISSION_BAT", submissionBatString);
            string updatedBAT_5 = updatedBAT_4.Replace("TEMPLATE_COMPANY_BAT", companyBatString);
            string updatedBAT_6 = updatedBAT_5.Replace("TEMPLATE_JOB_BAT", jobBatString);



            string[] Herefish_Process_Bat = { updatedBAT_6 };
        

            Thread.Sleep(500);


            //designate the path where the herefish_process file will be created
            string batFilePath = salesForceFolder + "\\" + clientName + "\\" + "Bin" + "\\" + "herefish_process.bat";
            

            // Create a new file     
            File.WriteAllLines(batFilePath, Herefish_Process_Bat);
            


            //update activity log
            using (StreamWriter ActivityFile = File.AppendText(pathActivityLog))
            {
                ActivityFile.WriteLine(DateTime.Now.ToString() + " - herefish_process.bat file created by " + name + " - Notes: " + notes);
            }


        }







    }

}
