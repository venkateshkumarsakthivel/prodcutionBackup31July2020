({
	doInit : function(component, event, helper) {
		 helper.getAccountDetails(component);
	},

	 showEditPanel : function(component, event, helper) {
        console.log('In show edit panel');
        var recId = component.get("v.recordId");
        console.log('recordId'+recId);
        $A.createComponent(
            "c:ManageAccountInfo",
            {
                 "recordId": recId
            },
            function(newComponent, status, errorMessage){
                
                console.log(status);
                if (status === "SUCCESS") {
                    component.set("v.body", newComponent);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                
            }
        );


        /*var selectedItem = event.currentTarget;
        setTimeout(function()
        { 
        var ec = component.find("editDiv");
        $A.util.removeClass(ec, 'slds-hide');
        }, 800);
        document.getElementById("editPanel").style.display = "block";
         document.getElementById("editPanel").style.height = "393px";
        document.getElementById("editPanel").style.marginTop = "283px";  */
        // styleContainer.style.display = "block";
        //  styleContainer.style.height: "393px";
        //  styleContainer.style.margin-top: "283px";

    },
   
})