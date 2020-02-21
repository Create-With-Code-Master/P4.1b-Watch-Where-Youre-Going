---
layout: tabbed-assignment
---

# Submission Instructions

After completing the lesson:

1. Make sure that you have:
   - Commited your changes to the **{{site.data.assignment.git-curr-branch}}** branch.
   - Merged the **{{site.data.assignment.git-curr-branch}}** branch into your **master** branch.
   - Pushed your work to GitHub.
   - Confirmed that you see your changes on GitHub.
1. Then, make a copy of the [submission template][template].
1. Rename the template and move it to your class folder on your Google Drive.
1. Complete the template.
1. Submit as usual.

{% include submission-boilerplate.html %}

<!-- Don't edit links here, change them in _data/assignment.yml instead, -->

{% if site.data.assignment.lesson   %}[lesson]: <{{site.data.assignment.lesson}}>     {% endif %}
{% if site.data.assignment.slides   %}[slides]:   <{{site.data.assignment.slides}}>   {% endif %}
{% if site.data.assignment.template %}[template]: <{{site.data.assignment.template}}> {% endif %}
