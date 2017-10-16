# README

This is an example of how to implements the checkout.fi API in rails.
It is based on the example in php from checkout.fi (php code is left as comments in the 'payment' model)

Currently only part of the Payment API is implemented 
* Payment and shop-in-shop payment:
  * get the payment buttons
  * verify and process the response


Things NOT yet covered in this example:
* Payment API
  * Authorization hold
  * Retract authorization hold
  * Commit payment
  * Fetch trade info
  * Refund
* Polling API
* Tokenization API

Clone this code, run 'bundle install' and 'rake db:migrate' and see it work. 
