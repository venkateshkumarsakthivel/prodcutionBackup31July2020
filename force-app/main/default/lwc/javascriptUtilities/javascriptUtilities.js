import {  fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'     //Show Toast Event library



//Get next char
const getNextCharacter = (c) => {
        if(emptyCheck(c)){
            return '';
        }
        return String.fromCharCode(c.charCodeAt(0) + 1);
    }


const notifyParentToggleSpinner = (flag) => {
        // if(!this.pageRef)
        // {
             var pageRef = {};
             pageRef.attributes = {};
             pageRef.attributes.LightningApp = "LightningApp";
        // }
         fireEvent(pageRef, 'toggleSpinner', flag);
     }


//Show toast message
const showToast = (title, message, type) => {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        dispatchEvent(event);
    }     

//Empty Check
const emptyCheck = (field) =>{
    if([undefined, null, '', {}, NaN].includes(field)){
        return true;
    }
    return false;
}    



    //Check blank space rows 
const checkBlankRowsinList = (list) => {
        for(var i in list){
            if(emptyCheck(list[i])){
                return true;
            }
        }
       return false; 
    }

    //Returns true if duplicates present otherwise false
const checkDuplicatesinList = (list) => {
        for(var i in list){
            for(var j in list){
                if(i!=j && list[i] == list[j]){
                    return true;
                }
            }
        }

        return false;
    }



    export{
        getNextCharacter,
        notifyParentToggleSpinner,
        showToast,
        emptyCheck,
        checkBlankRowsinList,
        checkDuplicatesinList
    }