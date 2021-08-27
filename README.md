# VIDO
**A GTK3 Video Downloader**

Download online videos from various sources including archive.org and much more!

<p align="left">
  <a href="https://appcenter.elementary.io/com.github.bernardodsanderson.vido"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter" /></a>
</p>

![Screenshot](https://raw.githubusercontent.com/bernardodsanderson/vido/master/data/images/VIDO-normal.png)

## Dependencies

Please make sure you have these dependencies first before building.

```
glib-2.0
granite
gtk+-3.0
youtube-dl
```
To build locally:

`flatpak-builder build  com.github.bernardodsanderson.vido.yml --user --install --force-clean`