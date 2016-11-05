% HOW-TO-USE
% proj = simulinkproject
% addFile(proj,'../sendEmail.m');

function status = sendEmail(subject, content, files)
    status = -1;
    
    % Email Settings
    address = 'matlab@zsn.cc';
    password = 'INFO2016me';
    smtp = 'smtp.exmail.qq.com';
    setpref('Internet','E_mail',address); 
    setpref('Internet','SMTP_Server',smtp);
    setpref('Internet','SMTP_Username',address);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.auth', 'true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port', '465');

    sendmail(address, subject, content, files);

    status = 1;
    
end