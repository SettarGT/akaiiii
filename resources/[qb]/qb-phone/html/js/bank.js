var FoccusedBank = null;

$(document).on('click', '.bank-app-account', function(e){
    var copyText = document.getElementById("iban-account");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");

    QB.Phone.Notifications.Add("fas fa-university", "QBank", "Hesab nömrəsi kopyalandı!", "#badc58", 1750);
});

var CurrentTab = "accounts";

$(document).on('click', '.bank-app-header-button', function(e){
    e.preventDefault();

    var PressedObject = this;
    var PressedTab = $(PressedObject).data('headertype');

    if (CurrentTab != PressedTab) {
        var PreviousObject = $(".bank-app-header").find('[data-headertype="'+CurrentTab+'"]');

        if (PressedTab == "invoices") {
            $(".bank-app-"+CurrentTab).animate({
                left: -30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        } else if (PressedTab == "accounts") {
            $(".bank-app-"+CurrentTab).animate({
                left: 30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        }

        $(PreviousObject).removeClass('bank-app-header-button-selected');
        $(PressedObject).addClass('bank-app-header-button-selected');
        setTimeout(function(){ CurrentTab = PressedTab; }, 300)
    }
})

QB.Phone.Functions.DoBankOpen = function() {
    QB.Phone.Data.PlayerData.money.bank = (QB.Phone.Data.PlayerData.money.bank).toFixed();
    $(".bank-app-account-number").val(QB.Phone.Data.PlayerData.charinfo.account);
    $(".bank-app-account-balance").html("₣ "+QB.Phone.Data.PlayerData.money.bank);
    $(".bank-app-account-balance").data('balance', QB.Phone.Data.PlayerData.money.bank);

    $(".bank-app-loaded").css({"display":"none", "padding-left":"30vh"});
    $(".bank-app-accounts").css({"left":"30vh"});
    $(".qbank-logo").css({"left": "0vh"});
    $("#qbank-text").css({"opacity":"0.0", "left":"9vh"});
    $(".bank-app-loading").css({
        "display":"block",
        "left":"0vh",
    });
    setTimeout(function(){
        CurrentTab = "accounts";
        $(".qbank-logo").animate({
            left: -12+"vh"
        }, 500);
        setTimeout(function(){
            $("#qbank-text").animate({
                opacity: 1.0,
                left: 14+"vh"
            });
        }, 100);
        setTimeout(function(){
            $(".bank-app-loaded").css({"display":"block"}).animate({"padding-left":"0"}, 300);
            $(".bank-app-accounts").animate({left:0+"vh"}, 300);
            $(".bank-app-loading").animate({
                left: -30+"vh"
            },300, function(){
                $(".bank-app-loading").css({"display":"none"});
            });
        }, 1500)
    }, 500)
}

$(document).on('click', '.bank-app-account-actions', function(e){
    QB.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
});

$(document).on('click', '#cancel-transfer', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
});

$(document).on('click', '#accept-transfer', function(e){
    e.preventDefault();

    var iban = $("#bank-transfer-iban").val();
    var amount = $("#bank-transfer-amount").val();
    var amountData = $(".bank-app-account-balance").data('balance');

    if (iban != "" && amount != "") {
            $.post('https://qb-phone/CanTransferMoney', JSON.stringify({
                sendTo: iban,
                amountOf: amount,
            }), function(data){
                if (data.TransferedMoney) {
                    $("#bank-transfer-iban").val("");
                    $("#bank-transfer-amount").val("");

                    $(".bank-app-account-balance").html("₣ " + (data.NewBalance).toFixed(0));
                    $(".bank-app-account-balance").data('balance', (data.NewBalance).toFixed(0));
                    QB.Phone.Notifications.Add("fas fa-university", "QBank", "Siz ₣ köçürdünüz "+amount+"!", "#badc58", 1500);
                } else {
                    QB.Phone.Notifications.Add("fas fa-university", "QBank", "Balansınız kifayət deyil!", "#badc58", 1500);
                }
                QB.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
            });
    } else {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Bütün xanaları doldurun!", "#badc58", 1750);
    }
});

GetFakturaLabel = function(type) {
    retval = null;
    if (type == "request") {
        retval = "Ödəniş tələbi";
    }

    return retval
}

$(document).on('click', '.pay-invoice', function(event){
    event.preventDefault();

    var FakturaId = $(this).parent().parent().parent().attr('id');
    var FakturaData = $("#"+FakturaId).data('invoicedata');
    var BankBalance = $(".bank-app-account-balance").data('balance');

    if (BankBalance >= FakturaData.amount) {
        $.post('https://qb-phone/PayFaktura', JSON.stringify({
            sender: FakturaData.sender,
            amount: FakturaData.amount,
            society: FakturaData.society,
            invoiceId: FakturaData.id,
            senderCitizenId: FakturaData.sendercitizenid
        }), function(CanPay){
            if (CanPay) {
                $("#"+FakturaId).animate({
                    left: 30+"vh",
                }, 300, function(){
                    setTimeout(function(){
                        $("#"+FakturaId).remove();
                    }, 100);
                });
                QB.Phone.Notifications.Add("fas fa-university", "QBank", "You have paid &#36;"+FakturaData.amount+"!", "#badc58", 1500);
                var amountData = $(".bank-app-account-balance").data('balance');
                var NewAmount = (amountData - FakturaData.amount).toFixed();
                $("#bank-transfer-amount").val(NewAmount);
                $(".bank-app-account-balance").data('balance', NewAmount);
            } else {
                QB.Phone.Notifications.Add("fas fa-university", "QBank", "Balansınız kifayət deyil!", "#badc58", 1500);
            }
        });
    } else {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Balansınız kifayət deyil!", "#badc58", 1500);
    }
});

$(document).on('click', '.decline-invoice', async function(event) {
    event.preventDefault();
    var FakturaId = $(this).parent().parent().parent().attr('id');
    var FakturaData = $("#"+FakturaId).data('invoicedata');

    const resp = await $.post('https://qb-phone/DeclineFaktura', JSON.stringify({
        sender: FakturaData.sender,
        amount: FakturaData.amount,
        society: FakturaData.society,
        invoiceId: FakturaData.id,
    }));
    if(resp === true) {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Fakturanı imtina etdiniz", "#8c7ae6")
        $("#"+FakturaId).animate({
            left: 30+"vh",
        }, 300, function(){
            setTimeout(function(){
                $("#"+FakturaId).remove();
            }, 100);
        });
    } else {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Fakturanı imtina etmək mümkün olmadı...", "#8c7ae6")
    }
});

QB.Phone.Functions.LoadBankFakturas = function(invoices) {
    if (invoices !== null) {
        $(".bank-app-invoices-list").html("");

        $.each(invoices, function(i, invoice){
            var Elem = '<div class="bank-app-invoice" id="invoiceid-'+invoice.id+'"> <div class="bank-app-invoice-title">'+invoice.society+' <span style="font-size: 1vh; color: gray;">(Göndərən: '+invoice.sender+')</span></div>' + (typeof invoice.reason === 'string' ? `<div class="bank-app-invoice-reason">${invoice.reason}</div>` : '') + '<div class="bank-app-invoice-info"><div class="bank-app-invoice-amount">₣ '+invoice.amount+'</div> <div class="bank-app-invoice-buttons"> <i class="fas fa-check-circle pay-invoice"></i>'+ (invoice.candecline === 1 ? '<i class="fas fa-times-circle decline-invoice"></i>' : '') + '</div></div></div>';

            $(".bank-app-invoices-list").append(Elem);
            $("#invoiceid-"+invoice.id).data('invoicedata', invoice);
        });
    }
}

QB.Phone.Functions.LoadContactsWithNumber = function(myContacts) {
    var ContactsObject = $(".bank-app-my-contacts-list");
    $(ContactsObject).html("");
    var TotalContacts = 0;

    $("#bank-app-my-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".bank-app-my-contacts-list .bank-app-my-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            var RandomNumber = Math.floor(Math.random() * 6);
            var ContactColor = QB.Phone.ContactColors[RandomNumber];
            var ContactElement = '<div class="bank-app-my-contact" data-bankcontactid="'+i+'"> <div class="bank-app-my-contact-firstletter">'+((contact.name).charAt(0)).toUpperCase()+'</div> <div class="bank-app-my-contact-name">'+contact.name+'</div> </div>'
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-bankcontactid='"+i+"']").data('contactData', contact);
        });
    }
};

$(document).on('click', '.bank-app-my-contacts-list-back', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});

$(document).on('click', '.bank-transfer-mycontacts-icon', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideDown(".bank-app-my-contacts", 400, 0);
});

$(document).on('click', '.bank-app-my-contact', function(e){
    e.preventDefault();
    var PressedContactData = $(this).data('contactData');

    if (PressedContactData.iban !== "" && PressedContactData.iban !== undefined && PressedContactData.iban !== null) {
        $("#bank-transfer-iban").val(PressedContactData.iban);
    } else {
        QB.Phone.Notifications.Add("fas fa-university", "QBank", "Bu nömrəyə bağlı bank hesabı yoxdur!", "#badc58", 2500);
    }
    QB.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});