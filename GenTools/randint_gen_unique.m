%Generate distinct Random Integers

function b = randint_gen_unique(mixtures,interval)
% close all;
% clear all;
% if nargin<3
%     state=[];
% end
tmp=interval(1):interval(2);
if mixtures>interval(2) || mixtures > length(tmp)
    error('More elementes required than length of the interval');
end
a=1:interval(2);
% b=randi(mixtures,1,interval);
b=randi(interval,mixtures,1);
% a=[interval(1):interval(2)];
lena=length(a);
lenb=length(b);
a(b)=[];
a(1:interval(1)-1)=[];
if ~isempty(a)
%     display('here');
    for i=1:length(b)
        for j=i+1:length(b)
            if b(i)==b(j) 
%                 c=randint(1,1,[1 length(a)]);
                c=randi([1 length(a)],1,1);
                b(i)=a(c);
                a(c)=[];      
            end      
        end
    end
end