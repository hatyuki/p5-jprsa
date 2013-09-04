$(function ( ) { "use strict";
    var crypt
    var private_key
    var public_key

    $(window).on('load', function (ev) {
        $('#newkey').trigger('click')
        $('#generate').trigger('click')
    } )

    $('#newkey').on('click', function (ev) {
        ev.preventDefault( )

        crypt = new JSEncrypt( { default_key_size: 1024 } )
        crypt.getKey( )
        private_key = crypt.getPrivateKey( )
        public_key  = crypt.getPublicKey( )

        $('#private-key').empty( ).append(private_key)
        $('#public-key').empty( ).append(public_key)
    } )

    $('#generate').on('click', function (ev) {
        var $this = $(this)
        ev.preventDefault( )

        $.ajax( {
            url: $this.data('href'),
            type: 'POST',
            data: { pubkey: public_key },
            dataType: 'text',
            success: function (cryptogram) {
                var plain = crypt.decrypt(cryptogram)
                $('#cryptogram').empty( ).append(cryptogram)
                $('#plain-text').empty( ).append(plain)
            }
        } )
    } )
} )
