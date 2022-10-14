%%
close all;
clear all;
clc;


%% CONSTANTS
asset           = 'ETHUSDT';
Tnumber         = 50;
data            = binance_klines(asset,'30m','limit',Tnumber);
val             = zeros(height(data), 1);
sigma           = 50;

% Data Normalisation
minval          = min(data.low(1));
data.high(:)    = data.high(:)./minval;
data.low(:)     = data.low(:)./minval;
data.open(:)    = data.open(:)./minval;
data.close(:)   = data.close(:)./minval;

[zigzag_indicator,zigzag_loc,zigzag_descriptor]    = zigzag(data);

%% MARKET FRACTALS
figure
tiledlayout(2,1)

ax1 = nexttile;
plot(data.Time([zigzag_indicator(:,1)]),zigzag_indicator(:,2),'b');
for i=1:height(zigzag_indicator)-1
    x = [data.Time(zigzag_descriptor(i,2)) data.Time(zigzag_descriptor(i,4)) ...
        data.Time(zigzag_descriptor(i,6)) data.Time(zigzag_descriptor(i,8))];
    y = [zigzag_descriptor(i,3) zigzag_descriptor(i,5) zigzag_descriptor(i,7) ...
        zigzag_descriptor(i,9)];
    po = patch(x,y,'white');
    po.FaceAlpha = 0.01;
end

%% OUTSIDE AND INSIDE BARS
ind_val     = strings(height(data)-1,1);
ind_val(:)  = 'none';

ax2 = nexttile;
hold on
for i = 2:height(data)
    % outside bar
    if gt(data.high(i), data.high(i-1)) && ...
            lt(data.low(i), data.low(i-1))
        x = [data.Time(i-1) data.Time(i) data.Time(i) data.Time(i-1)];
        y = [data.low(i-1) data.low(i) data.high(i) data.high(i-1)];
        po = patch(x,y,'r');
        po.FaceAlpha = 0.3;
        po.EdgeColor = 'none';
        % Indexing
        ind_val(i-1)  = 'outside';
    end
    % inside bar    
    if lt(data.high(i), data.high(i-1)) && ...
            gt(data.low(i), data.low(i-1))
        x = [data.Time(i-1) data.Time(i) data.Time(i) data.Time(i-1)];
        y = [data.low(i-1) data.low(i) data.high(i) data.high(i-1)];
        pi = patch(x,y,'r');
        pi.FaceAlpha = 0.3;
        pi.EdgeColor = 'none';
        % Indexing
        ind_val(i-1)  = 'inside';
    end
    
end
candle(data,'k');
for i = 1:height(data)
    text(data.Time(i),data.low(i),num2str(i))
end
hold off
linkaxes([ax1 ax2], 'x')

%% GENERAL OVERVIEW OF PRICE PATTERNS

% | Bear Trend | Bear Trading Range | Bull Trading Range | Bull Trend |
% | 1          | 2                  | 3                  | 4          |
tot_trend_bars = 0;
total_range_bars = 0;
signal_ind1 = zeros(height(data),1);
signal_ind2 = zeros(height(data),1);

for i = 1:height(data)
    val(i) = (1.0 - ((abs(data.high(i)-data.low(i)) - ...
                abs(data.open(i)-data.close(i)))/...
                abs(data.high(i)-data.low(i))))*100;
    co = (data.close(i) - data.open(i));

    % Check for Bull or Bear Bar
    if gt(co,0)
        val1 = 'Bull';
        tot_trend_bars = tot_trend_bars + 1;
    else
        val1 = 'Bear';
        tot_trend_bars = tot_trend_bars + 1;
    end

    % Check for Trend Type
    if ge(val(i), sigma)
        val2 = 'Trend Bar';
        total_range_bars = total_range_bars + 1;
    else
        val2 = 'Trading-Range Bar';
        total_range_bars = total_range_bars + 1;
    end

    if strcmp(val1,'Bull') && strcmp(val2,'Trend Bar')
        signal_ind1(i) = 4;
    elseif strcmp(val1,'Bull') && strcmp(val2,'Trading-Range Bar')
        signal_ind1(i) = 3;
    elseif strcmp(val1,'Bear') && strcmp(val2,'Trading-Range Bar')
        signal_ind1(i) = 2;
    elseif strcmp(val1,'Bear') && strcmp(val2,'Trend Bar')
        signal_ind1(i) = 1;
    end

    if gt(i,1) && ne(i,height(data))
        sig_diff_back = abs(signal_ind1(i) - signal_ind1(i-1));
        if gt(sig_diff_back,1)
            signal_ind2(i) = 1;
        end
    end

    disp(['Bar Count ',num2str(i),'; ',' [',num2str(signal_ind1(i)),']-[',...
        num2str(signal_ind2(i)),']; ',val1,' ',val2])





end