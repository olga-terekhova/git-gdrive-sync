This repository is for testing synchronization between a Google Drive folder and a folder within a Git repo.  
The main purpose is to establish a more robust version control when working with Google Colab notebooks.  
Google Drive is the preferred hosting while the development is active, as it autosaves the notebook.  
However, once ready to commit, one needs to save to GitHub manually by choosing the appropriate repo and typing the path to the notebook, which is very error-prone.  
This repo explores strategies for more automated synchronization between Google Drive and local git / GitHub.  

An example of the automated workflow which syncs the notebooks that have been changed, strips them of cell outputs, and pushes changes into git:  
1. The script mirrors the content of the source Google Drive directory into the target directory in a local file system.  
It identifies that two notebooks have been changed, and it removes cell outputs and run counts from the notebooks.  
<img src="./docs/screen_1.png" width="800">  
  
2. The script locates the repo which contains the target directory with the notebooks.  
It runs ```git status``` on the repo and allows the user to choose the next action: add, commit, push, or interrupt execution.  
<img src="./docs/screen_2.png" width="800">  
  
3. If the user chooses to add changes to stage, the script runs ```git add -A```.  
It shows the updated repo status, and invites the user to confirm proceeding to committing.  
<img src="./docs/screen_3.png" width="800">  
  
4. If the user agrees to commit, the script gets the commit message from the user response.  
It runs ```git commit -m```, shows the updated repo status, and invites the user to confirm proceeding to pushing.  
<img src="./docs/screen_4.png" width="800">  
  
5. If the user agrees to push, the script runs ```git push``` (or any command like ```git push origin/main```, specified in parameters).  
It shows the updated repo status, and asks the user if another iteration of reviewing the repository is needed.  
<img src="./docs/screen_5.png" width="800">  
  
6. If the user confirms, the process starts again from Step 2.  
If the user declines, the script exits.  
<img src="./docs/screen_6.png" width="800">  
  
  