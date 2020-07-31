({
	doInit : function(component, event, helper) {
        
        // Check if Licence Market Value and Levy Due values are populated
        // If Authorisation contact (buyer) does not have portal access, create a new user for them with a profile Taxi Licence Prospect.
        helper.validateCaseData(component, event);
        
    },    
    sendInvite : function(component, event, helper) {
        
        helper.inviteProposedOwner(component, event);
    },
    resendInvite: function(component, event, helper) {
        $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
        $A.util.toggleClass(component.find("inviteBuyerMailResend"), "toggle");
        helper.reInviteProposedOwner(component, event);
    }
})