function _918250d0dbb05b689805b20ae55659de70d3a393(){};var VERSION;VERSION="DEV";if(VERSION==="LOCAL"||VERSION==="DEV"){window.onerror=function(c,b,a){alert(""+c+" "+a);return false}}window.util={VERSION_NUMBER:"1.0.4",WEB_SERVICE_BASE_URL:(function(){switch(VERSION){case"LOCAL":return"http://192.168.0.3:3000/";case"PROD":return"https://purpledelivery.com/";case"DEV":return"http://purple-dev.elasticbeanstalk.com/"}})(),STRIPE_PUBLISHABLE_KEY:(function(){switch(VERSION){case"LOCAL":return"pk_test_HMdwupxgr2PUwzdFPLsSMJoJ";case"PROD":return"pk_live_r8bUlYTZSxsNzgtjVAIH7bcA";case"DEV":return"pk_test_HMdwupxgr2PUwzdFPLsSMJoJ"}})(),GCM_SENDER_ID:"254423398507",MINIMUM_GALLONS:10,GALLONS_INCREMENT:5,GALLONS_PER_TANK:5,STATUSES:["unassigned","assigned","enroute","servicing","complete","cancelled"],NEXT_STATUS_MAP:{unassigned:"assigned",assigned:"accepted",accepted:"enroute",enroute:"servicing",servicing:"complete",complete:"complete",cancelled:"cancelled"},CANCELLABLE_STATUSES:["unassigned","assigned","accepted","enroute"],ctl:function(a){return Purple.app.getController(a)},flashComponent:function(d,a){var b=this;if(a==null){a=5000}d.show();return setTimeout((function(){return d.hide()}),a)},centsToDollars:function(a){return(a/100).toFixed(2)}};