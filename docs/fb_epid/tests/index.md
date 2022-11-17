---
layout: default
title: Tests
parent: EPID Feedback
has_children: true
nav_order: 3
---


Use of the EPID record for feedback at UNICAT 
=============================================  

It became apparent from [initial testing](fb_epid/tests/20040623) that the epid record provided by synApps would need to be wrapped with a database to provide some useful features for our users. A [first cut at a database](fb_epid/tests/20040727) provided some very encouraging results.  After revision, a [second round of testing](fb_epid/tests/20041025) was arranged with a database used to provide active feedback to keep the beam vertical position constant (on the Oxford Quadrant X-ray Beam Position Monitor in 33ID-D) using the monochromator omega2 piezo as a positioner (in 33ID-C). When the sscan record was used to step-scan the XBPM vertical position, the new database performed quite well.   The database was then further revised to the [present form](fb_epid). 

