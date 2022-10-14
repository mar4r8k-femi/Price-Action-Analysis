function [T,w,response] = binance_klines(symbol,interval,varargin,OPT)

arguments
    symbol          (1,:) char
    interval        (1,:) char
end
arguments (Repeating)
    varargin
end
arguments
    OPT.limit       (1,1) = 1000000
end
assert(nargin <= 3 && nargin >= 2,...
    sprintf('Expected 2-3 positional input arguments, but was %d.',nargin))
assert(nargout <= 3,'To many output arguments.')
OPT.symbol = upper(symbol);
OPT.interval = interval;
tZone = 'local';
if nargin == 3
    
    validateattributes(varargin{1},{'datetime','double'},{'row','numel',2})
    t = varargin{1};
    
    if isa(varargin{1},'datetime')
        

        if isempty(t.TimeZone) 
            t.TimeZone = tZone;     
        else
            tZone = t.TimeZone;     
        end
        t = round(posixtime(t)*1e3);       
        
    end
    
    OPT.startTime = t(1);
    OPT.endTime = t(2);
    
end
response = sendRequest(OPT,'/api/v3/klines','GET');
w = getWeights(response);
if isempty(response.Body.Data)
    
    T = [];
    
else
    
    Ta = horzcat(response.Body.Data{:}).';
    
    time = datetime([Ta{:,1}]*1e-3,'ConvertF','posixtime','TimeZone',tZone).';
    
    OHLCV = cellfun(@str2double,Ta(:,2:6));
    
    quoteVolume = cellfun(@str2double,Ta(:,8));
    numTrades = [Ta{:,9}].';
    
    T = array2timetable([OHLCV quoteVolume numTrades],...
        'RowTimes',time,'VariableNames',...
        {'open','high','low','close','volume','quoteVolume','numTrades'});
end
end
function w = getWeights(s)
idx = find( ismember( [s.Header.Name],...
    ["x-mbx-used-weight","x-mbx-used-weight-1m"] ) );
w = str2double([s.Header(idx).Value]);
end