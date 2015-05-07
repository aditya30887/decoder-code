bmi_ros_integration
===================

MATLAB API for people to use while developing BMIs with the Plexon system and ROS. It is a library of matlab convenience functions for communicating with the ROS system. This repository also has some code samples that can be run in a ROS network. For convenience, there are also functions that mimic the behavior of ROS communication, but run locally without the need for access to a running ROS master.


Included:
---------
1. API code for use in your own BMIs
2. Dummy BMI example (online)
3. Dummy BMI example (offline)

Requirements:
-------------
* Windows 7 or greater
* MATLAB 2015a or greater
* [Plexon Client SDK](http://www.plexon.com/sites/default/files/downloads/Matlab%20Online%20Client%20Development%20Kit-mexw.zip)
** This includes SoftServer, which is needed for the offline simulation
* [Plexon Offline SDK](http://www.plexon.com/sites/default/files/downloads/OmniPlex%20and%20MAP%20Offline%20SDK%20Bundle.zip) (for offline sim only)
* Network access to a ROS master node on your LAN (for online execution only)



Overview:
---------
A BMI needs to communicate with:

* Plexon PlexServer (Or SoftServer for offline prototyping)
* ROS network

To use the ROS network to get things like real-hand kinematics, task states, or goal positions, use the provided `ros_interface` class. For an example of its usage for polling those parameters, see `example_offline.m`. If you need anything else from the ROS side, that can totally be implemented. 


Example (online):
-----------------
(nothing yet)



Example (offline):
------------------
This example shows a simple BMI that:
1. Loads some pre-recorded data, pre-trains a BMI (gamma filter, linear model, cartesian hand position)
2. Initializes plexon and ros clients
3. runs a main loop that polls new firing rate and new ROS variables
4. predicts output with rate (or alternatively, updates bmi model, see comments)
5. plots