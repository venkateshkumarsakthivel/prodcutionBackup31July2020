({
	applicantRegister: function(component, event, helper){
       console.log('In applicantRegister');
       helper.handleRegister(component, event);
    },
    
    navigateToHome : function(component, event, helper) {        
        window.location = '/industryportal/s';
    },
    
    setApplicationType:function(component, event, helper){
        console.log('set application type');
        console.log(event);
    }
})