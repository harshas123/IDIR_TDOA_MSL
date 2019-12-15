function [V,nr,nre]=lcon2vert_ver3(A,b,Aeq,beq,TOL)
%An extension of Michael Kleder's con2vert function, used for finding the 
%vertices of a bounded polyhedron in R^n, given its representation as a set
%of linear constraints. This wrapper extends the capabilities of con2vert to
%also handle cases where the  polyhedron is not solid in R^n, i.e., where the
%polyhedron is defined by both equality and inequality constraints.
% 
%SYNTAX:
%
%  [V,nr,nre]=lcon2vert(A,b,Aeq,beq,TOL)
%
%The rows of the N x n matrix V are a series of N vertices of the polyhedron
%in R^n, defined by the linear constraints
%  
%   A*x  <= b
%   Aeq*x = beq
%
%By default, Aeq=beq=[], implying no equality constraints. The output "nr"
%lists non-redundant inequality constraints, and "nre" lists non-redundant 
%equality constraints.
%
%The optional TOL argument is a tolerance used for both rank-estimation and 
%for testing feasibility of the equality constraints. Default=1e-10.
%
%EXAMPLE: 
%
%The 3D region defined by x+y+z=1, x>=0, y>=0, z>=0
%is described by the following constraint data.
% 
%     A =
% 
%         1.0000    1.0000   -2.0000
%        -2.0000    1.0000    1.0000
%         1.0000   -2.0000    1.0000
% 
% 
%     b =
% 
%         1.0000
%         1.0000
%         1.0000
% 
% 
%     Aeq =
% 
%         1.0000    1.0000    1.0000
% 
% 
%     beq =
% 
%          1
%
%  >> V=lcon2vert(A,b,Aeq,beq)
% 
%         V =
% 
%             1.0000    0.0000    0.0000
%            -0.0000    1.0000         0
%                  0    0.0000    1.0000
%
%




  %%initial argument parsing
  
  nre=[];
  nr=[];
  if nargin<5, TOL=1e-10; end
  
  switch nargin 
      
      case 0
          
           error 'At least 1 input argument required'
          return
          
      
      case 1
        
         b=[]; Aeq=[]; beq=[]; 
        
          
      case 2
          
          Aeq=[]; beq=[];
          
      case 3
          
          beq=[];
          error 'Since argument Aeq specified, beq must also be specified'
            
  end
  
  
  b=b(:); beq=beq(:);
  
  if xor(isempty(A), isempty(b)) 
     error 'Since argument A specified, b must also be specified'
  end
      
  if xor(isempty(Aeq), isempty(beq)) 
        error 'Since argument Aeq specified, beq must also be specified'
  end
  
  
  nn=max(size(A,2)*~isempty(A),size(Aeq,2)*~isempty(Aeq));
  
  if ~isempty(A) && ~isempty(Aeq) && ( size(A,2)~=nn || size(Aeq,2)~=nn)
      
      error 'A and Aeq must have the same number of columns if both non-empty'
      
  end
  
  
  inequalityConstrained=~isempty(A);  
  equalityConstrained=~isempty(Aeq);

 [A,b]=rownormalize(A,b);
 [Aeq,beq]=rownormalize(Aeq,beq);
 
  if equalityConstrained && nargout>2
 
        
        nre=licols([Aeq,beq].',TOL); 
          
        if ~isempty(nre) %reduce the equality constraints
            
            Aeq=Aeq(nre,:);
            beq=beq(nre);
            
        else    
            equalityConstrained=false;
        end
        
   end
      

  
   %%Find 1 solution to equality constraints within tolerance
  
            
   if equalityConstrained
        
        
       Neq=null(Aeq);   


       x0=pinv(Aeq)*beq;

       if norm(Aeq*x0-beq)>TOL*norm(beq),  %infeasible

          nre=[]; nr=[]; %All constraints redundant for empty polytopes
          V=[]; 
          return;
          
       elseif isempty(Neq)

           V=x0(:).'; 
           nre=(1:nn).'; %Equality constraints determine everything. 
           nr=[];%All inequality constraints are therefore redundant.             
           return
           
       end
 
       rkAeq= nn - size(Neq,2);
       
       
  end  
   
    %%
  if inequalityConstrained && equalityConstrained
     
   AAA=A*Neq;
   bbb=b-A*x0;
    
  elseif inequalityConstrained
      
    AAA=A;
    bbb=b;
   
  elseif equalityConstrained && ~inequalityConstrained
      
       error('Non-bounding constraints detected. (Consider box constraints on variables.)')
      
    
  end
  
  nnn=size(AAA,2);
  

  if nnn==1 %Special case
      
     idxu=sign(AAA)==1;
     idxl=sign(AAA)==-1;
     idx0=sign(AAA)==0;
     
     Q=bbb./AAA;
     U=Q; 
       U(~idxu)=inf;
     L=Q;
       L(~idxl)=-inf;

     
     [ub,uloc]=min(U);
     [lb,lloc]=max(L);
     
     if ~all(bbb(idx0)>=0) || ub<lb %infeasible
         
         V=[]; nr=[]; nre=[];
         return
         
     elseif ~isfinite(ub) || ~isfinite(lb)
         
         error('Non-bounding constraints detected. (Consider box constraints on variables.)')
         
     end
      
     Zt=[lb;ub];
     
     if nargout>1
        nr=unique([lloc,uloc]); nr=nr(:);
     end
     
      
  else    
      
          if nargout>1
           [Zt,nr]=con2vert(AAA,bbb);
          else
            Zt=con2vert(AAA,bbb); 
          end
  
  end
  


  if equalityConstrained
     
      V=bsxfun(@plus,Zt*Neq.',x0(:).'); 
      
  else
      
      V=Zt;
      
  end
 

  function [V,nr] = con2vert(A,b)
% CON2VERT - convert a convex set of constraint inequalities into the set
%            of vertices at the intersections of those inequalities;i.e.,
%            solve the "vertex enumeration" problem. Additionally,
%            identify redundant entries in the list of inequalities.
% 
% V = con2vert(A,b)
% [V,nr] = con2vert(A,b)
% 
% Converts the polytope (convex polygon, polyhedron, etc.) defined by the
% system of inequalities A*x <= b into a list of vertices V. Each ROW
% of V is a vertex. For n variables:
% A = m x n matrix, where m >= n (m constraints, n variables)
% b = m x 1 vector (m constraints)
% V = p x n matrix (p vertices, n variables)
% nr = list of the rows in A which are NOT redundant constraints
% 
% NOTES: (1) This program employs a primal-dual polytope method.
%        (2) In dimensions higher than 2, redundant vertices can
%            appear using this method. This program detects redundancies
%            at up to 6 digits of precision, then returns the
%            unique vertices.
%        (3) Non-bounding constraints give erroneous results; therefore,
%            the program detects non-bounding constraints and returns
%            an error. You may wish to implement large "box" constraints
%            on your variables if you need to induce bounding. For example,
%            if x is a person's height in feet, the box constraint
%            -1 <= x <= 1000 would be a reasonable choice to induce
%            boundedness, since no possible solution for x would be
%            prohibited by the bounding box.
%        (4) This program requires that the feasible region have some
%            finite extent in all dimensions. For example, the feasible
%            region cannot be a line segment in 2-D space, or a plane
%            in 3-D space.
%        (5) At least two dimensions are required.
%        (6) See companion function VERT2CON.
%        (7) ver 1.0: initial version, June 2005
%        (8) ver 1.1: enhanced redundancy checks, July 2005
%        (9) Written by Michael Kleder
%
%Modified by Matt Jacobson - March 30, 2011
% 

% Added by Harsha
% ****************************************************
% A(find(A<10^-10))=0;
% b(find(b<10^-10))=0;
% ****************************************************
    c = A\b; %Initializer0
    inside=all(A*c < b,1);
    
    if ~inside %Initializer1
        
        c=Initializer1(A,b,c);
        inside=all(A*c < b,1);
    end
    
    if ~inside %Attempt refinement
        
        disp 'It is unusually difficult to find an interior point of your polytope. This may take some time... '
        %disp ' '   
        
        c=Initializer2(A,b,c);
        [c,fval]=Initializer1(A,b,c,10000);
        inside=all(A*c < b,1); 
        
       
    end
  
    
    if ~inside
            error('Unable to locate a point within the interior of a feasible region.')
    end
    
    
    b = b - A*c;
    
    %D = A ./ repmat(b,[1 size(A,2)]);   
    D=bsxfun(@rdivide,A,b); %Matt Jacobson upgraded the above line
    
    [k,v2] = convhulln([D;zeros(1,size(D,2))]);
    [k,v1] = convhulln(D);
    if v2 > v1
        error('Non-bounding constraints detected. (Consider box constraints on variables.)')
    end
    nr = unique(k(:));
    G  = zeros(size(k,1),size(D,2));
    for ix = 1:size(k,1)
        F = D(k(ix,:),:);
        G(ix,:)=F\ones(size(F,1),1);
    end
    
    %V = G + repmat(c',[size(G,1),1]);  
    V = bsxfun(@plus, G, c.'); %Matt Jacobson upgraded the above line
    
    [null,I]=unique(num2str(V,6),'rows');
    V=V(I,:);
    
return


function [c,fval]=Initializer1(A,b,c,maxIter)
       
    
    
    thresh=-10*max(eps(b));
    
    if nargin>3
     [c,fval]=fminsearch(@(x) max([thresh;A*x-b]), c,optimset('MaxIter',maxIter));
    else
     [c,fval]=fminsearch(@(x) max([thresh;A*x-b]), c); 
    end
    
return          


function c=Initializer2(A,b,c)
 %norm(  (I-A*pinv(A))*(s-b) )  subj. to s>=0 
  
 
    
    maxIter=10000;
 
    [mm,nn]=size(A);
    
    
    
    
     Ap=pinv(A);        
     Aaug=speye(mm)-A*Ap;
     Aaugt=Aaug.';

    
    M=Aaugt*Aaug;
    C=sum(abs(M),2);
     C(C<=0)=min(C(C>0));
    
    slack=b-A*c;
    slack(slack<0)=0;
    
     
    relto=norm(b);
    relto =relto + (relto==0); 
    
     relres=norm(A*c-b)/relto;

     
     
    s=slack; 
    ii=0;
    %for ii=1:maxIter
    while relres>1e-6 
    
     s=s-Aaugt*(Aaug*(s-b))./C;   
     s(s<0)=0;
      ii=ii+1; 
      
       c=Ap*(b-s);
       relres=norm(A*c-b)/relto;
       if all(A*c<b,1)||relres<1e-6||ii==maxIter, break;  end
       
    end
   
return 




function [idx,Xsub]=licols(X,tol)
%Extract a linearly independent set of columns of a given matrix X
%
%    [Xsub,idx]=licols(X)
%
%in:
%
%  X: The given input matrix
%  tol: A rank estimation tolerance. Default=1e-10
%
%out:
%
% Xsub: The extracted columns of X
% idx:  The indices (into X) of the extracted columns

   if ~nnz(X) %X has no non-zeros and hence no independent columns
       
       Xsub=[]; idx=[];
       return
   end

   if nargin<2, tol=1e-10; end
   

           
     [Q, R, E] = qr(X,0); 
     
     diagr = abs(diag(R));


     %Rank estimation
     r = find(diagr >= tol*diagr(1), 1, 'last'); %rank estimation

     idx=sort(E(1:r));
       idx=idx(:);

     if nargout>1
      Xsub=X(:,idx);                      
     end                     

     
 function [A,b]=rownormalize(A,b)
 %Modifies A,b data pair so that norm of rows of A is either 0 or 1
 
  if isempty(A), return; end
 
  normsA=sqrt(sum(A.^2,2));
  idx=normsA>0;
  A(idx,:)=bsxfun(@rdivide,A(idx,:),normsA(idx));
  b(idx)=b(idx)./normsA(idx);       
        
        
     