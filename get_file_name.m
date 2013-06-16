function name = get_file_name(filename)
n = 1;
while true
    if filename(n) ~= '.'
        n = n+1;
    else
        name = filename(1:n-1);
        break;
    end
end
