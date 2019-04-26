# CSE-573-Semantic-Web-Mining-Project
Personality Classification with Social Media

Environment Setup:
1. This project requires RStudio 1.2 to be installed on the computer.
2. In the terminal, run the following commands to install packages:

	install.packages("Matrix")
	install.packages("irlba")
	install.packages("topicmodels")

Data:
1. Download the data from the following link:
  https://drive.google.com/file/d/15v2umVbv1OarPfNrePH9V-KPk7qqA6Cg/edit
2. Unzip the downloaded file and copy paste the files 'users.csv', 'likes.csv' and 'user-likes.csv' into the data folder.

Runtime Instructions:
1. To run the program, open terminal and navigate to the code folder inside project.
2. Run the command "Rscript FinalCode.R".
3. To use LDA instead of SVD for dimensionality reduction, comment the lines 48-50 and uncomment the lines 53-54.