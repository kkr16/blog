---
title: "Montreal metro line status in Home Assistant"
date: 2024-12-04T00:00:00Z
draft: false
tags: [ha, home assistant, home automation, stm, metro, transit, montreal] 
---
#  Montreal metro mayhem? Not on Home Assistant's watch!

Ever been rushing to work only to find your metro line is down?  Frustrating, right?  Well, I've got a Home Assistant solution that'll keep you one step ahead of the STM gremlins. 

The Société de transport de Montréal (STM) has a developer portal with tons of data ([GTFS feeds](https://www.stm.info/en/about/developers)), but who has time to sift through all that? I just wanted a simple way to see the metro line status.  

Turns out, there's an easy way!  Instead of building a complex system, I found a clever shortcut using Home Assistant's built-in `scrape` integration. 

I found the Metro service status [page](https://www.stm.info/en/info/service-updates/metro), and figured I'd simply scrape these. I initially expected to have to write some Python to scrape and exract the status, but it turned out it was much easier than I though. Home Assistant comes with a standard [scrape](https://www.home-assistant.io/integrations/scrape/) integration that uses the [BeautifulSoup](https://pypi.org/project/beautifulsoup4/) Python library. 

##  Quick Setup - No Coding Required!
Just paste this into your Home Assistant `configuration.yaml` file and restart HA:

```
scrape:
  - resource: https://www.stm.info/en/info/service-updates/metro
    scan_interval: 120
    sensor:
      - name: "STM Green Line"
        select: "section > p"
        index: 0
        unique_id: stm_green
        icon: mdi:subway-variant
      - name: "STM Orange Line"
        select: "section > p"
        index: 1
        unique_id: stm_orange
        icon: mdi:subway-variant
      - name: "STM Yellow Line"
        select: "section > p"
        index: 2
        unique_id: stm_yellow
        icon: mdi:subway-variant
      - name: "STM Blue Line"
        select: "section > p"
        index: 3
        unique_id: stm_blue
        icon: mdi:subway-variant
```
This tells Home Assistant to check the STM website every 120 seconds and grab the status of each line. Easy peasy!  

## Status Updates at a Glance

Once you restart Home Assistant, you'll have four new sensors: `sensor.stm_green`, `sensor.stm_orange`, `sensor.stm_blue`, and `sensor.stm_yellow`.

These sensors will show you the current status of each line, like:
* Normal métro service
* Service interruption continues on the 2 - ORANGE line, between Lionel-Groulx and Beaubien due to an incident. Service expected to resume at 8:55 PM.
* Service interruption on the 2 - ORANGE line, between Lionel-Groulx and Beaubien due to an intervention by emergency services. Service expected to resume at 8:45 PM.
* Service interruption on the BLUE line, between Snowdon and Saint-Michel due to a train breakdown. Service expected to resume at 9:35 PM.

## Level up your commute!
Now the fun part!  Add these sensors to your Lovelace dashboard:
![](/img/stm-metro-status-ha.png)

But wait, there's more!  With these sensors, you can create awesome automations:
* Notifications: Get a notification on your phone if your usual line is down, around your typical commute times.
* Smart Home Magic: Change your smart lights to red if there's a delay on your line, so you know to leave earlier, or maybe plan to work from home on that day.
* Commute Dashboard: Build a dedicated dashboard with real-time metro status, weather, and traffic updates.

This is just the beginning!  Get creative and personalize your Home Assistant setup to conquer your Montreal commute.

/kr
