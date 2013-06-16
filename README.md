# BTC<sup>2</sup>


BTC<sup>2*</sup> is the result of the Bitcoin 2013 Conference Hackathon, San Jose, on May 17-19, 2013. 

The result a first draft of a Bluetooth Low Energy based Bitcoin transaction protocol to simplify Bitcoin transactions between people in the same room. 

The protocol enables discovery of other people with the ability to send or receive Bitcoins using this system and a very simple transaction mechanism to improve user experience. 

As of the current version (v0.01) it's mostly a UX concept. 

Big thanks to Robohash.org for an amazingly awesome service! Made my hackathon presentation way more awesome. 

 -- Joakim


*BTC<sup>2</sup> is BtcBTC (Bitcoin BlueTooth Communication)

-------------------------

# Services & Characteristics

## Overview

Bluetooth Low Energy (BLE) is part of the Bluetooth v4.0 specification. It defines a simple interface to create custom services and characteristics without the need to register UUIDs with the Bluetooth SIG. 

BLE devices has 1 of 2 modes; central or peripheral. In a client/server environment, the central would be the client and the peripheral is the server; it holds all the data. Normally the central READ data from the peripheral but it can also WRITE data. BLE also enables the peripheral to initiate data transfer using NOTIFICATIONS or INDICATIONS. 

A peripheral advertises one or more of it's contained services and the central can scan for peripherals with a specific service. 

Each service has one or more characteristics, which are data endpoints. Each characteristic in turn can have descriptors but we don't care about them currently. 

A service or characteristic is identified by a UUID. The Bluetooth SIG specify a specific Base UUID which all their pre-defined services and characteristics are based upon. We do the same for BTC<sup>2</sup> and to not collide with other UUIDs we generate one and make it pretty. 

May I present the BTC<sup>2</sup> Base UUID! **00000000-AAA7-4E52-BB94-03EF9B262830**. Pretty!

Now how does this work? The BLE specification identifies all services and characteristics adding a 16bit or 32bit identifier to their Base UUID. (We're only using 16bit identifiers.)

0000xxxx-AAA7-4E52-BB94-03EF9B262830, xxxx marks the spot where the 16bit identifier lives. Why do they do this? To save valuable battery-draining air time. The Base UUID is sent once and the rest of the communication is based on the 16bit identifiers. 

Which brings us to an important point. BLE is _LOW ENERGY_ (duh). It is not meant to be a solution for all our problems, just for the battery specific ones. Hence, there are some limitations we need to keep in mind. A characteristic normally contain **20** bytes of data. That's not a whole lot. Bandwidth is also low. Without tweaking parameters we got a few thousand bits per second in throughput. Reminds me of the good ol' 3200 baud modem days. 

Luckily, a bitcoin wallet address is pretty small (33 bytes) so we shouldn't be too hampered by this slow transmission. If it does get too slow though we can easily tweak the BLE link to 20kbit/s or more at the cost of battery drainage. 

## BTC<sup>2</sup> custom services

We want bitcoin transfers to be dead simple. Users should be able to find each other easily and transact bitcoins even easier. Since BLE is central/peripheral based it's easy to make this simple for the central. It's a bit trickier to make it easy for the person that end up as a peripheral, since the peripheral can't read data from a central. We have a solution though. 

BTC<sup>2</sup> defines 3 custom services: 
- Wallet service, mandatory
- Identification service, optional but recommended
- Service provider service, optional

### Wallet service
This is the service you are looking for. It's a basic service with 3 characteristics (actually it's 6, we'll get to that). 
- Wallet address characteristic. Your 33 byte wallet address where you want people to put bitcoins. Can optionally be encrypted.
- Payment request characteristic. People you owe money will ask for payment using this characteristic. Can optionally be encrypted. 
- Notice characteristic. This should be used as a mechanism to provide feedback that a transaction has occurred but it can have other purposes as well. Can optionally be encrypted.

To make coin transfer easy for the peripheral side, we need to duplicate the characteristics. 

- Wallet address Read characteristic. Central READs the wallet address from the peripheral. 
- Wallet address Write characteristic. Central WRITEs it's wallet address to the peripheral. 
- Payment request Write characteristic. Central WRITEs a payment request to the peripheral. 
- Payment request Indicate characteristic. Peripheral INDICATEs that a payment request is initiated.
- Notice Write characteristic. Central WRITEs that it has transferred bitcoins.  
- Notice Indicate characteristic. Peripheral INDICATEs that it has transferred bitcoins.  

A bit complex but luckily the user doesn't have to know. 

### Identification service
This service defines a way to present users to each other. It consists of 3 (6) characteristics currently but that may be reduced. 

- Pseudonym Read characteristic. Central READs the peripherals pseudonym. This should be used in the UI. 
- Pseudonym Write characteristic. Central WRITEs it's pseudonym to the peripheral. 
- Avatar READ characteristic. Central READs an avatar service ID and avatar ID from the peripheral.
- Avatar Write characteristic. Central WRITEs it's avatar service ID and avatar ID to the peripheral. 
- Avatar URL Read characteristic. Central READs the peripherals avatar image URL. 
- Avatar URL Write characteristic. Central WRITEs it's avatar image URL to the peripheral.  

Name and image. A simple way to distinguish between users in a room. The avatar URL characteristic is meant as a general image URL. The avatar characteristic will be for defined avatar services, like gravatar or robohash. 

### Service provider service
We want BTC<sup>2</sup> to be an open cross platform/service protocol but an implementor should still be able to customise it. This service is meant to facilitate that. The service provider service enables service providers (wallet providers, social networks etc) to identify which service is hosting this particular BLE broadcast and which user is behind the device. This is an **optional** service. Always keep privacy in mind when using this and the identification service. 

- Service provider name Read characteristic. Central READs the service name from the peripheral. 
- Service provider name Write characteristic. Central WRITEs it's service name to the peripheral. 
- User ID Read characteristic. Central READs the User ID from the peripheral. 
- User ID Write characteristic. Central READs write it's User ID to peripheral. 

That's the gist of it. The data formats for the different characteristics are defined in the code. 


