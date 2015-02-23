#!/usr/bin/perl
# by Yuriy Kolodovskyy aka Lexx
# kolodovskyy@ukrindex.com
# +380445924814
# last 20150216

use Digest::MD5 qw(md5 md5_hex md5_base64);
use MIME::Base64;
use Encode qw(encode);
use Text::Iconv;

sub PL_main
{
  my $KEY = 'KEY';
  my $PASSWORD = 'PASSWORD';
  my $STAT_URL = 'STAT_HOST';

  my $PAYMENT = 'CC';
  my $ACTION = 'https://secure.platononline.com/payment/auth';
  my $SUCCESS_URL = "$STAT_URL$script?uu=$F{uu}&pp=$F{pp}&a=$F{a}&result=success";
  my $FAIL_URL = "$STAT_URL$script?uu=$F{uu}&pp=$F{pp}&a=$F{a}&result=fail";

  if ($F{result} eq 'success') {
    &OkMess('Оплата зроблена успішно');
    return;
  } elsif ($F{result} eq 'fail') {
    &ErrorMess('Помилка сплати або відмова');
    return;
  }

  $paket=&sql_select_line($dbh, "SELECT price, name FROM plans2 WHERE id=" . $pm->{paket});

  $paket->{name} =~ s/^\[\d+\]//g;
  &Message("
    <h2>Сплата через Platon</h2><br>
    <b>ПІБ:</b> $pm->{fio}<br>
    <b>Номер договору:</b> $pm->{name}<br>
    <b>Поточний тарифний план: </b>$paket->{name}<br>
    <b>Вартість: </b>$paket->{price}&nbsp$gr"
  );

  my $amount = $F{amount};
  $amount =~ s/,/\./g;
  $amount = sprintf("%01.2f", $amount);

  if ($F{process} && $amount >= 10) {
    &sql_do($dbh, "INSERT INTO s_platon SET mid='$pm->{id}', amount='$amount'");
    $order = $dbh->last_insert_id(undef,undef,'s_platon','id');

    $iconv = Text::Iconv->new("windows-1251", "utf-8");
    $description = $iconv->convert($pm->{fio}.' (договор '.$pm->{name}.')');

    my $data = encode_base64('{"amount":"'.$amount.'","currency":"UAH","description":"'.$description.'"}','');
    my $sign = md5_hex(uc(
      reverse($KEY).
      reverse($PAYMENT).
      reverse($data).
      reverse($SUCCESS_URL).
      reverse($PASSWORD)
    ));

    &Message("
      <div class=nav nowrap>
       <b>Пополнение баланса на сумму: </b>$amount&nbsp$gr<br><br>
       <form accept-charset=\"UTF-8\" name=\"payform\" method=\"POST\" action=\"$ACTION\">
          <input type=\"hidden\" name=\"key\" value=\"$KEY\">
          <input type=\"hidden\" name=\"payment\" value=\"$PAYMENT\">
          <input type=\"hidden\" name=\"order\" value=\"$order\">
          <input type=\"hidden\" name=\"data\" value=\"$data\">
          <input type=\"hidden\" name=\"url\" value=\"$SUCCESS_URL\">
          <input type=\"hidden\" name=\"error_url\" value=\"$FAIL_URL\">
          <input type=\"hidden\" name=\"sign\" value=\"$sign\">
          <input type=submit value='Перейти до сплати'>
        </form></div>");
  } else {
    &Message(
      &form('!'=>1,'process'=>'yes',
        "<span class=data2><font color=red>Мінімальна сума платежу 10 грн</font></span><br><br>".
        "<b>Сума до оплати: </b>".
        &input_t("amount",sprintf("%01.2f",$paket->{price}),10,10)." $gr".$br2.
        &submit_a('Сплатити'))
    );
  }
}
1;
