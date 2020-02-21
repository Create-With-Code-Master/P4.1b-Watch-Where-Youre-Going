---
layout: tabbed-assignment
---

# Resources

{% if site.data.assignment.slides %}
* [Presentation Slides][slides]
{% endif %}
{% if site.data.assignment.template %}
* [Submission Template][template]
{% endif %}
* [Lesson][]

<!-- Don't edit links here, change them in _data/assignment.yml instead. -->

{% if site.data.assignment.lesson   %}[lesson]: <{{site.data.assignment.lesson}}>     {% endif %}
{% if site.data.assignment.slides   %}[slides]:   <{{site.data.assignment.slides}}>   {% endif %}
{% if site.data.assignment.template %}[template]: <{{site.data.assignment.template}}> {% endif %}
