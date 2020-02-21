---
layout: tabbed-assignment
---

# Instructions

{% include time-estimate.html %}

<p><details><summary>Start your notes.</b></summary>
  
 - Start a page for this lesson in your notebook with a **title and date**.
 - Check you notes from the previous class to see where to start.
 - Review the [learning targets](learning-targets.html) to see what you should be focusing on learning and understanding.

</details></p>

<p><details><summary>Launch <b>GitHub Desktop</b> and make sure that your <b>{{site.data.assignment.starter-code-repo}}</b> repository is up to date.</summary>

- Make sure that your **{{site.data.assignment.starter-code-repo}}** repository is selected.
- Do a **fetch** to make sure your local copy of the code is up to date, if you have done work on the GitHub site or at home between classes you will be prompted to do a **pull** to incorporate your changes.

{% if site.data.assignment.git-prev-branch %}
- Make sure that you are on the **{{site.data.assignment.git-prev-branch}}** branch.
{% endif %}

</details></p>

{% if site.data.assignment.git-prev-branch %}
  <p><details><summary>Create and publish a {{site.data.assignment.git-curr-branch}} branch.</summary>
{% else %}
  <p><details><summary>Confirm that you are on your {{site.data.assignment.git-curr-branch}} branch.</summary>

  If necessary, create the **{{site.data.assignment.git-curr-branch}}** branch.
{% endif %}
    
- Select the **Current Branch** drop down.
- Click on the **New Branch** button.
- Enter **{{site.data.assignment.git-curr-branch}}** in the **Name** field.
- Click on the **Create Branch** button.

</details></p>

<p><details><summary>Go to the <a href="{{site.data.assignment.lesson}}">lesson</a> and work through the videos.</summary>

Work in a loop:

- Watch a video
- As you watch outline the video in your notes
- Make notes on the new material:
  - Vocabulary
  - The Unity user interface
  - Implementing game mechanics.
- After watching a video, do the process you just learned

  Use your notes and the cues below each video to help you remember what to do, **but do not try to do the lesson without watching the video** - there is a wealth of information in the video that you won't get by just following the cues.
- After completing the work for each video, commit your changes:
  - Save the scene in Unity and your scripts in Visual Studio Code, then
  - Go to **GitHub Desktop** - once you click on GitHub Desktop you should see a list of changed files.
  
  If you do not your first priority is to troubleshoot. The most likely cause is that you forgot to save. If that is not the problem, then it is likely that Unity and GitHub Desktop are looking at different folders. Fix that now. If you've just started on the project the easiest thing to do may be to start over.  
  - Write a brief summary of what you did.
  - Click the **Commit** button.

</details></p>

<p><details><summary>Merge your work to the <b>master</b> branch.</summary>

After you have finished all of the videos for the lesson, do one final test to ensure that the prototype is working as expected. Then:

- Go to GitHub Desktop.
- Confirm that you have no uncommitted changes. If you do, commit them. Then test again.
- Switch to the **master** branch.
- Click on the **Current Branch** drop down again, and then on the **Choose a branch to merge into master** button at the bottom of the drop down.
- From the list of branches choose the **{{site.data.assignment.git-curr-branch}}**.
- Click on the blue **Merge {{site.data.assignment.git-curr-branch}} into master** button.
- Push your changes to GitHub.

  After pushing, use the **View on GitHub** button in GitHub Desktop to go to your repository on GitHub and confirm that your changes are visible.
- While videos remain, repeat with next video.

</details></p>

<p><details><summary>Update your notes.</summary>

Before wrapping up at the end of the period, make sure that you have committed and pushed your latest changes and that you've updated your notes to show how far you have gotten. This will be helpful when you figure out where to pick up next class.

</details></p>

<p><details><summary>Submit your work.</summary>

When you're finished, go to the submission tab, check the instructions, and submit.

</details></p>

<!-- Don't edit links here, change them in _data/assignment.yml instead. -->

{% if site.data.assignment.lesson   %}[lesson]: <{{site.data.assignment.lesson}}>     {% endif %}
{% if site.data.assignment.slides   %}[slides]:   <{{site.data.assignment.slides}}>   {% endif %}
{% if site.data.assignment.template %}[template]: <{{site.data.assignment.template}}> {% endif %}
