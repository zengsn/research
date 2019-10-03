%FACE RECOGNITION SYSTEM
%
% Face recognition system based on EigenFaces Method.
% The system functions by projecting face images onto a feature space
% that spans the significant variations among known face images. The
% significant features are known as "eigenfaces" because they are the
% eigenvectors (principal components) of the set of faces.
%
% Face images must be collected into sets: every set (called "class") should
% include a number of images for each person, with some variations in 
% expression and in the lighting. When a new input image is read and added
% to the training database, the number of class is required. Otherwise, a new 
% input image can be processed and confronted with all classes present in database.
% We choose a number of eigenvectors M' equal to the number of classes (see 
% algorithmic details in the cited references). 
%
% The images included are taken from AT&T Laboratories Cambridge's
% Face DataBase. See the cited references for more informations.
% 
% 
% FUNCTIONS
%
% Select image:                   read the input image
%
% Add selected image to database: the input image is added to database and will be used for training
%
% Database Info:                  show informations about the images present in database. Images must 
%                                 have the same size. If this is not true you have to resize them.
%
% Face Recognition:               face matching. The selected input image is processed 
%
% Delete Database:                remove database from the current directory
%
% Info:                           show informations about this software
%
% Exit:                           quit program
%
%
%  References:
%  "Eigenfaces for Recognition", Matthew Turk and Alex Pentlad
%  Journal of Cognitive Neuroscience pp.71-86, March 1991
%  Vision and Modeling Group, The Media Laboratory
%  Massachusetts Institute of Technology.
%  This paper is available at http://www.cs.ucsb.edu/~mturk/Papers/jcn.pdf
%  See also Matthew Turk's homepage http://www.cs.ucsb.edu/~mturk/research.htm
%
%  AT&T Laboratories Cambridge. The ORL face database, Olivetti Research Laboratory available at
%  http://www.uk.research.att.com/pub/data/att_faces.zip
%  or http://www.uk.research.att.com/pub/data/att_faces.tar.Z
%
%
%
%Please contribute if you find this software useful.
%Report bugs to luigi.rosa@tiscali.it
%
%
%*****************************************************************
% Luigi Rosa
% Via Centrale 27
% 67042 Civita di Bagno
% L'Aquila --- ITALY 
% email  luigi.rosa@tiscali.it
% mobile +39 340 3463208 
% http://utenti.lycos.it/matlab
%*****************************************************************
%
%

%--------------------------------------------------------------------
clear;
clc;
chos=0;
possibility=7;

messaggio='Insert the number of set: each set determins a class. This set should include a number of images for each person, with some variations in expression and in the lighting.';

while chos~=possibility,
    chos=menu('Face Recognition System','Select image','Add selected image to database','Database Info','Face Recognition','Delete Database','Info','Exit');
    %----------------
    if chos==1,
        clc;
        [namefile,pathname]=uigetfile('*.*','Select image');
        if namefile~=0
            [img,map]=imread(strcat(pathname,namefile));
            imshow(img);
        else
            warndlg('Input image must be selected.',' Warning ')
        end
    end    
    %----------------
    if chos==2,
        clc;
        if exist('img')
            if (exist('face_database.dat')==2)
                load('face_database.dat','-mat');
                face_number=face_number+1;
                data{face_number,1}=img(:);
                prompt={strcat(messaggio,'Class number must be a positive integer <= ',num2str(max_class))};
                title='Class number';
                lines=1;
                def={'1'};
                answer=inputdlg(prompt,title,lines,def);
                zparameter=double(str2num(char(answer)));
                if size(zparameter,1)~=0
                    class_number=zparameter(1);
                    if (class_number<=0)||(class_number>max_class)||(floor(class_number)~=class_number)||(~isa(class_number,'double'))||(any(any(imag(class_number))))
                        warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                    else
                        if class_number==max_class;
                            max_class=class_number+1;
                        end
                        data{face_number,2}=class_number;
                        save('face_database.dat','data','face_number','max_class','-append');
                        msgbox(strcat('Database already exists: image succesfully added to class number ',num2str(class_number)),'Database result','help');
                        close all;
                        clear('img')
                    end
                else
                    warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                end
            else
                face_number=1;
                max_class=1;
                data{face_number,1}=img(:);
                prompt={strcat(messaggio,'Class number must be a positive integer <= ',num2str(max_class))};
                title='Class number';
                lines=1;
                def={'1'};
                answer=inputdlg(prompt,title,lines,def);
                zparameter=double(str2num(char(answer)));
                if size(zparameter,1)~=0
                    class_number=zparameter(1);
                    if (class_number<=0)||(class_number>max_class)||(floor(class_number)~=class_number)||(~isa(class_number,'double'))||(any(any(imag(class_number))))
                        warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                    else
                        max_class=2;
                        data{face_number,2}=class_number;
                        save('face_database.dat','data','face_number','max_class');
                        msgbox(strcat('Database was empty. Database has just been created. Image succesfully added to class number ',num2str(class_number)),'Database result','help');
                        close all;
                        clear('img')
                    end
                else
                    warndlg(strcat('Class number must be a positive integer <= ',num2str(max_class)),' Warning ')
                end
                
            end
        else
            errordlg('No image has been selected.','File Error');
        end
    end
    %----------------
    if chos==3,
        clc;
        close all;
        clear('img');
        if (exist('face_database.dat')==2)
            load('face_database.dat','-mat');
            msgbox(strcat('Database has ',num2str(face_number),' image(s). There are',num2str(max_class-1),' class(es). Input images must have the same size.'),'Database result','help'); 
        else
            msgbox('Database is empty.','Database result','help');
        end
    end
    %----------------
    if chos==4,
        clc;
        close all;
        if exist('img')
            ingresso=double(img(:));
            if (exist('face_database.dat')==2)
                load('face_database.dat','-mat');
                % face_number is equal to "M" of Turk's paper
                % i.e. the number of faces present in the database. 
                % These image are grouped into classes. Every class (or set) should include 
                % a number of images for each person, with some variations in expression and in the
                % lighting.
                matrice=zeros(size(data{1,1},1),face_number);            
                for ii=1:face_number
                    matrice(:,ii)=double(data{ii,1});
                end
                somma=sum(matrice,2);
                media=somma/face_number;
                for ii=1:face_number
                    matrice(:,ii)=matrice(:,ii)-media;
                end
                matrice=matrice/sqrt(face_number);
                % up to now matrix "matrice" is matrix "A" of Turk's paper
                elle=matrice'*matrice;
                % matrix "elle" is matrix "L" of Turk's paper
                
                % eigenvalues and eigenvectors of the "reduced" matrix  A'*A
                [V,D] = eig(elle);
                % the following multiplication is performed to obtain the
                % eigenvectors of the original matrix A*A' (see Turk's paper)
                Vtrue=matrice*V;
                Dtrue=diag(D);
                
                % the eigenvalues are sorted by order and only M' of them
                % are taken. We impose M' equal to the number of classes
                % (max_class-1)
                [Dtrue,ordine]=sort(Dtrue);
                Dtrue=flipud(Dtrue);
                ordine=flipud(ordine);                
                Vtrue(:,1:face_number)=Vtrue(:,ordine);
                
                Vtrue=Vtrue(:,1:max_class-1);
                Dtrue=Dtrue(1:max_class-1);
                
                % we calculate the eigenface components of
                % the normalized input (mean-adjusted). I.e. the input
                % image is projected into "face-space"
                pesi=Vtrue'*(ingresso-media);
                
                pesi_database=zeros(max_class-1,max_class-1);
                numero_elementi_classe=zeros(max_class-1,1);
                for ii=1:face_number
                    ingresso_database=double(data{ii,1});
                    classe_database=data{ii,2};
                    pesi_correnti=Vtrue'*(ingresso_database-media);
                    pesi_database(:,classe_database)=pesi_database(:,classe_database)+pesi_correnti;
                    numero_elementi_classe(classe_database)=numero_elementi_classe(classe_database)+1;
                end                
                for ii=1:(max_class-1)
                    pesi_database_mediati(:,ii)=pesi_database(:,ii)/numero_elementi_classe(ii);
                end
                % pesi_database_mediati is a matrix with the averaged eigenface components of the images 
                % present in database. Each class has its averaged eigenface.
                % We want to find the nearest (in norm) vector to the input
                % eigenface components.
                
                distanze_pesi=zeros(max_class-1,1);
                for ii=1:(max_class-1)
                    distanze_pesi(ii)=norm(pesi-pesi_database_mediati(:,ii));                    
                end
                
                [minimo_pesi,posizione_minimo_pesi]=min(distanze_pesi);
                
                % now we are evaluating the distance of the mean-normalized
                % input face from the "space-face" in order to detrmine if
                % the input image is a face or not.
                proiezione=zeros(size(data{1,1},1),1);
                for ii=1:(max_class-1)
                    proiezione=proiezione+pesi(ii)*Vtrue(:,ii);
                end
                distanza_spazio_facce=norm((ingresso-media)-proiezione);
                
                
                
                messaggio1='See Matlab Command Window to see matching result. The program has just calculated the minimal distance from classes and the distance from Face Space. ';
                messaggio2='You now should fix the two threshold-values to determine if this mathing is correct. If both distances are below the threshold values it means that the input ';
                messaggio3='face was correctly matched with a known face. If the distance from Face Space is below the threshold value but the minimal distance from classes is above the other threshold value, ';
                messaggio4=' it means that the input image is an unknown face. See the cited article for more informations.';
                
                msgbox(strcat(messaggio1,messaggio2,messaggio3,messaggio4),'Matching result','help');
                
                disp('The nearest class is number ');
                disp(posizione_minimo_pesi);
                disp('with a distance equal to ');
                disp(minimo_pesi);
                disp('The distance from Face Space is ');
                disp(distanza_spazio_facce);
                
                
                
                
            else
                warndlg('No image processing is possible. Database is empty.',' Warning ')
            end
        else
            warndlg('Input image must be selected.',' Warning ')
        end
    end
    %----------------
    if chos==5,
        clc;
        close all;
        if (exist('face_database.dat')==2)
            button = questdlg('Do you really want to remove the Database?');
            if strcmp(button,'Yes')
                delete('face_database.dat');
                msgbox('Database was succesfully removed from the current directory.','Database removed','help');
            end
        else
            warndlg('Database is empty.',' Warning ')
        end
    end
    %----------------
    if chos==6,
        clc;
        close all;
        helpwin facerecognition;
    end
    %----------------
end

