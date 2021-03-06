// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database. 
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

//Express
var express = require('express');
var app = express();

//Braintree
var braintree = require('braintree');

var gateway = braintree.connect({
  environment: braintree.Environment.Sandbox,
  merchantId: '94r6yc9kf8vdfp64',
  publicKey: 'bcnjzvdy53s7n96f',
  privateKey: 'de4d242eed3abd67272a015b7d89be94'
});

exports.client_token = functions.https.onRequest((req, res) => {
  	gateway.clientToken.generate({
  		customerId: req.body.customerId
  	}, function (err, response) {
     
        var clientToken = response.clientToken;
        res.send(clientToken);
        console.log(clientToken);

    });
});

exports.create_new_transaction = functions.https.onRequest((req, res) => {
    gateway.transaction.sale({
  		amount: req.body.amount,
  		customerId: req.body.customerId,
  		options: {
    		submitForSettlement: true
  		},
      deviceData: req.body.device_data
		}, function (err, result) {
      if (typeof result == 'undefined'){
        console.log(err);
      } else {
        if (result.success) {
          res.send("Transaction succeeded.");
          console.log("Transaction succeeded.");
          console.log(result.transaction.id);
        } else {
          console.log("Transaction failed.");
          console.log(result.errors);
          console.log(result.message);
          console.log(result.params);
        }
      }
      
	});
});

exports.create_new_customer = functions.https.onRequest((req, res) => {
    gateway.customer.create({

        id: req.body.uid,
        firstName: req.body.first_name,
        lastName: req.body.last_name,
        email: req.body.email,
        phone: req.body.phone_no

    }, function (err, result) {

      if (result.success) {
        res.send("Customer creation success.");
        console.log("Customer creation success.");
        console.log(result.customer.id);
      } else {
        console.log("Customer creation failed.");
        console.log(result.errors);
        console.log(result.message);
        console.log(result.params);
      }
    });
});

exports.create_payment_method = functions.https.onRequest((req, res) => {
    gateway.paymentMethod.create({
        customerId: req.body.uid,
        paymentMethodNonce: req.body.payment_method_nonce
    }, function (err, result) {
        if (result.success){
            res.send("Payment creation succeeded.");
            console.log("Payment creation succeeded.");
        } else {
            console.log("Payment creation failed.");
            console.log(result.errors);
            console.log(result.message);
            console.log(result.params);
        }
    });
});

//This function creates a new customer with a card payment method
exports.create_new_customer_and_payment = functions.https.onRequest((req, res) => {
    //debug
    if (req.body.payment_method_nonce != ""){
       console.log("Payment method nonce received:" + req.body.payment_method_nonce);
    } else {
       console.log("Payment method nonce empty.");
    }
    
    gateway.customer.create({

        id: req.body.uid,
        firstName: req.body.first_name,
        lastName: req.body.last_name,
        email: req.body.email,
        phone: req.body.phone_no

    }, function (err, result) {

        if (result.success) {
            console.log("Customer creation succeeded.");
            console.log(result.customer.id);

            gateway.paymentMethod.create({
              customerId: req.body.uid,
              paymentMethodNonce: req.body.payment_method_nonce,
              /*billingAddress: {
                firstName: req.body.cardholder_first_name,
                lastName: req.body.cardholder_last_name,
                streetAddress: req.body.billing_add_street,
                extendedAddress: req.body.billing_add_extended,
                locality: req.body.billing_add_city,
                region: req.body.billing_add_state,
                postalCode: req.body.billing_add_zip_code
              },
              options: {
                verifyCard: true
              }*/
            }, function (err2, result2) {
               if (result2.success){
                  console.log("Payment creation succeeded.");
               } else {
                  console.log("Payment creation failed.");
                  console.log(result.errors);
                  console.log(result2.message);
                  console.log(result2.params);
               }
            });

        } else {
            console.log("Customer creation failed.");
            console.log(result.errors);
            console.log(result.message);
            console.log(result.params);
        }

    });

});
