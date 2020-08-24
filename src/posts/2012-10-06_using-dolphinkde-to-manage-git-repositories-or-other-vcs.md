---
title: Using Dolphin/KDE to manage Git repositories (or other VCS)
author: Aécio Santos
permalink: /2012/10/06/using-dolphinkde-to-manage-git-repositories-or-other-vcs/
published_time: 2012-10-06T03:29:35+00:00
modified_time: 2015-11-05T18:47:26+00:00
content_type: markdown
---

# Using Dolphin/KDE to manage Git repositories (or other VCS)
*October 05, 2012*

Dolphin is the default file manager of
[KDE Plasma](https://en.wikipedia.org/wiki/KDE). It is very extensible and
allows you to install plugins that provide more nice features.
With the *KDE SDK plugins for Dolphin* it is possible to manage a Git repository
directly from the Dolphin GUI.
In KDE 4.8, the plugin also works with Bazaar, Subversion (SVN), and Mercurial.

To do that in Linux Mint, Ubuntu and similar distros, you just need to install the
package `kdesdk-dolphin-plugins` by running:

```
sudo apt-get install kdesdk-dolphin-plugins
```

After that, you need to enable the feature:

1. Open Dolphin and go to menu *Settings > Configure Dolphin…*
2. Click in the tab *Services*.
3. Check the option Git (and any other Version Control System you want to use).
4. Confirm the changes by clicking in *Apply/OK*.
5. Restart Dolphin.

After that, whenever you enter a folder that is a Git repository, Dolphin will
show some info about the repository, such as files that have changed.
The following figure shows an example. When you click with the right button
in the folder (or files), the context menu shows you options to checkout,
commit, create tags, pull and push.
It may be a very useful tool even if you know how to use Git's command line
interface.

Here is how it looks like:

<img class="img-responsive" src="/static/img/dolphin-git.png" alt="Options using Dolphin Git Plugin"></img>
