function response = sendRequest(s,endPoint,requestMethod,OPT)

arguments
    s                (1,1) struct
    endPoint         (1,:) char
    requestMethod    (1,:) char
    OPT.xmapikey     (1,1) logical = false
end

import matlab.net.*

if isfield(s,'username')
    
    [akey,skey] = trykeys(s.username);
    
    s = rmfield(s,'username');                     
    
    s.timestamp = pub.getServerTime();              
    
elseif OPT.xmapikey

    akey = trykeys(); 
    
end

QP = QueryParameter(s);                             
queryString = QP.char;

if exist('skey','var') == 1
    signature = HMAC(skey,queryString);
    queryString = [queryString '&signature=' signature];  	
end

if exist('akey','var') == 1
    header = http.HeaderField('X-MBX-APIKEY',...
        akey,'Content-Type','application/x-www-form-urlencoded');
else
    header = http.HeaderField('Content-Type',...
        'application/x-www-form-urlencoded');
end


if ismember(requestMethod,{'POST'})
    
    URL = [getBaseURL endPoint];
    
    request = http.RequestMessage(requestMethod,header,...
        http.MessageBody(queryString)...
        );
    
else
    
    URL = [getBaseURL endPoint '?' queryString];
    
    request = http.RequestMessage(requestMethod,header);
    
end

response = request.send(URL);

manageErrors(response,s)

end

function varargout = trykeys(varargin)
    if nargin ==1
        username = varargin{1};
    else
        username = 'default';
    end

    try
        if nargout == 2
            [akey,skey]=getkeys(username);
            varargout{1} = akey;
            varargout{2} = skey;
        else
           varargout{1} =getkeys(username);
        end
    catch ME
        if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
            msg = sprintf(['Undefined function getkeys.m\n\n'...
                'To setup a getkeys.m file, refer to either the <a href='...
                '"https://github.com/hughestu/MATLAB-Binance-API"'...
                '>GitHub docs</a>\nor the template function in; '...
                'subfunctions/getkeys_Template.m']);
            throwAsCaller(MException('MATLAB:UndefinedFunction',msg))
        else
            rethrow(ME)
        end
    end
end




