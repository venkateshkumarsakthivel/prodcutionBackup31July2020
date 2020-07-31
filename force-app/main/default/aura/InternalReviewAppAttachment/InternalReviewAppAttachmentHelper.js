({
	renderNextSection : function(component, event, closeForm, reviewSave) {
        this.showSpinner(component, event);
        var _action = component.get("c.saveSectionData"); 
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");
        
        _action.setParams({"jsonStr":JSON.stringify(internalDetailsWrp)});
         _action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
                var returnedValue = response.getReturnValue();
                if(returnedValue.isSuccess && returnedValue.csObj.Id && returnedValue.csObj.Id.startsWith("500")){
                    component.set("v.reviewFormWrpObj", returnedValue); 
                    // show toast only when finish later is clicked
                    if(closeForm == true) {
                        var toastEvent = $A.get("e.force:showToast");           	
	                    toastEvent.setParams({
	                        "title": "Success",
	                        "message": "Application saved successfully.",
	                        "type": "success",
	                        "duration":10000,
	                        "mode": "dismissible" 
	                    });
	                    toastEvent.fire(); 
	                    var disableModal = component.getEvent("closeInternalReviewModal");
                        disableModal.fire();
                    }if(reviewSave) {
	                    component.set("v.readOnly", true);
	                    component.set("v.reviewEdit", false);
	                }else{
                        var _nextSectionEvent = component.getEvent("loadSection");
				        _nextSectionEvent.setParams({
				            "sectionNameToRender": "Privacy Statement", 
				            "reviewFormWrpObj" : component.get("v.reviewFormWrpObj"), 
				            "modalHeightInPercent":"height:90%"
				        });
				        _nextSectionEvent.fire();
				     }
                                     
                }else if(returnedValue.message.startsWith("Entered authorisation number")){
                    component.find("Auth-Lic-Num-Input").set("v.errors", [{message:returnedValue.message}]);
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();                                       
                }else{
                    // will be replaced with proper error handling
                    alert(returnedValue.message);
                }               
                
            }else if(state ==="ERROR"){
                // will be replaced with proper error handling
                alert(response.getReturnValue());
            }
             
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(_action);
        
	},
    performDocumentCheck : function (component, event){		//throw error if checkbox is checked but documents are not uploaded
        document.getElementById("documentsNotUploadedError").innerHTML = '';
        var internalDetailsWrp 		= component.get("v.reviewFormWrpObj");
        var documentUploadCheck     = internalDetailsWrp.csObj.Internal_Review_Supporting_Documents__c;
        var documentUploadStatus 	= component.get("v.documentUploadStatus");
        var returnStatus 			= false;
        var caseAlreadyHasDocuments = internalDetailsWrp.caseAlreadyHasDocuments;
   
         var action = component.get("c.attachmentUploadedCheck");
         action.setParams({ "caseId":internalDetailsWrp.csObj.Id});
         action.setCallback(this, function(response){
             var state = response.getState();
             if(state === "SUCCESS"){
                 var returnedValue = response.getReturnValue();
                 component.set("v.reviewFormWrpObj.caseAlreadyHasDocuments", returnedValue);
                 caseAlreadyHasDocuments = component.get("v.reviewFormWrpObj.caseAlreadyHasDocuments");               
                 
                 console.log('checked'+documentUploadCheck);
                 console.log('uploadStatus'+documentUploadStatus);
                 console.log('hasDocs'+caseAlreadyHasDocuments);

                 if(documentUploadCheck){
                     if(caseAlreadyHasDocuments){
                         this.renderNextSection(component, event, false, false);
                     }else{
                         if(documentUploadStatus == undefined || documentUploadStatus == false){
                             document.getElementById("documentsNotUploadedError").innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
                             document.getElementById("documentsNotUploadedError").style.display = 'block';
                             document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
                             document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
                         }						
                     }
                 }else{
                     if(documentUploadStatus){
                         document.getElementById("documentsNotUploadedError").innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
                         document.getElementById("documentsNotUploadedError").style.display = 'block';
                         document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
                         document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
                     }else{
                         this.renderNextSection(component, event, false, false);
                     }
                 }
                 
             }else if(state ==="ERROR"){
                  //this.hideSpinner(component, event);
                //alert(response.getReturnValue());
            }   
         });
         $A.enqueueAction(action);
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})