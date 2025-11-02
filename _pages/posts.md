---
layout: archive
title: "All posts"
permalink: /posts/
---
{% assign sorted_articles = site.articles | sort: 'date' | reverse %}
{% for post in sorted_articles %}
  {% unless post.hidden %}
    {% include archive-single.html %}
  {% endunless %}
{% endfor %}
