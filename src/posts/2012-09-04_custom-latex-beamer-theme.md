---
title: A simple & clean Latex Beamer theme
author: Aécio Santos
permalink: /2012/09/04/custom-latex-beamer-theme/
#published_time: September 9, 2012
published_time: 2012-09-04T04:06:41+00:00
modified_time: 2016-05-14T20:55:49+00:00
content_type: markdown
---

# A simple & clean Latex Beamer theme
*September 4, 2012*

Beamer is a great Latex class used to create presentations.
Unfortunately, most default Beamer themes are very bloated and full of
stuff that waste the usefull space of the slides.
Looking for simplicity, I created a custom beamer theme that is simple and clean.

If you already know latex and beamer, it’s pretty easy to use it. Just download
the file [`style.tex`](https://github.com/aecio/beamer-theme/blob/master/style.tex)
and put it on the same folder of you latex document.
Then, you just need to include the file using the command `\input{style.tex}` at
the begining of your latex document. The structure of your document should look
like this:

```
\documentclass[t,14pt,mathserif]{beamer}
% include your packages

\input{style.tex}

\title{Presentation Title}
\author{Author Name}

\begin{document}
  % your document content
\end{document}
```

You can download the theme from GitHub:
[https://github.com/aecio/beamer-theme](https://github.com/aecio/beamer-theme).
There you will also find a demo presentation, and a PDF of the demo presentation
generated using the theme.
You can use this demo as a template for your own presentations.

Here is how it looks like (I said it was very simple!):

<img src="{{site.base_url}}/static/img/beamer-theme.png" class="img-responsive"></img>
