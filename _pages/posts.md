---
layout: archive
title: "All posts"
permalink: /posts/
---
{% for post in site.posts %}
  {% unless post.hidden %}
    {% include archive-single.html %}
  {% endunless %}
{% endfor %}
