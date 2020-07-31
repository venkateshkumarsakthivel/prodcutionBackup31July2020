({
	doInit : function(component, event, helper) {
    console.log('Inside doinit');
	$(function() {
		// Use the Preview environment
		
		Harmony.useEnv(Harmony.ENV_PREVIEW);
		console.log('Inside doinit');
		Harmony.init("Shrikant Hase", "shrikant12", Harmony.AUSTRALIA);
		
		// Use the JSONP protocol
		Harmony.useProtocol(Harmony.JSONP);

		$( "#noticeaddress" ).autocomplete({
			// minimum number of entered characters before trying to search
			minLength:3,
			// miliseconds to wait before trying to search
			delay:500,   
	   			 			   
			source: function(request, response) {							
			
				Harmony.address({ fullAddress : request.term }, Harmony.AUPAF, 
					function(data) {					
					
					var array = [];							
					if(data.status == Harmony.SUCCESS) {   
						array = $.map(data.payload, function(p) {
							return {
								label: p.fullAddress,
							};
						});
						response(array);
					}
				});
			},
			focus: function(event, ui) {
				// prevent autocomplete from updating the textbox
				event.preventDefault();
				// manually update the textbox
				$(this).val(ui.item.label);
			},
			select: function(event, ui) {
				// prevent autocomplete from updating the textbox
				event.preventDefault();
				// manually update the textbox
				$(this).val(ui.item.label);				
			}			
		});
	});
	},
    
    test:function(component,event){
        console.log("In test");
    }
})