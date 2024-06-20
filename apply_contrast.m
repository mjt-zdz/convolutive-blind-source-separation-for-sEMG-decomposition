function y = apply_contrast(x, fun, der)
%{
This function applies a mathematical contrast function and it's fist and
second derivatives to an input vector x. 

Inputs
    REQUIRED
    x: The input vector.
    
    fun: The contrast fucntion specified by a string. Options available
    are:
        "skew": x^3/3
        "log_cosh": log(cosh(x))
        "exp_sqr": exp(-x^2/2)

    der: Specifies which derivative order of the contrast function should
    be applied to the vector x. Specified as string:
        "der": applies the first derivative of the contrast function
        "der_der": applies the second derivative of the contrast function
        any other string or empty: applies the function itself to the vector x

Outputs
    y: 
        G(x) contrast function itself
    or 
        g(x) first derivative of the contrast function
    or 
        g'(x)  second derivative of the contrast function

%}

arguments
    x double
    fun string
    der string
end

switch fun

    case "skew"
        switch der
            case "der"
                y = x.^2;
            case "der_der"
                y = 2.*x;
            otherwise
                y = (x.^3)/3;
        end

    case "log_cosh"
        switch der
            case "der"
                y = tanh(x);
            case "der_der"
                y = (sech(x)).^2;
            otherwise
                y = log(cosh(x));
        end

    case "exp_sqr"
        switch der
            case "der"
                y = -x.*exp(-(x.^2)/2);
            case "der_der"
                y = -exp(-(x.^2)/2) + (x.^2).*(exp(-(x.^2)/2));
            otherwise
                y = exp(-(x.^2)/2);
        end
    case "kurtosis"
        switch der
            case "der"
                y=x.^3;
            case "der_der"
                y=3*(x.^2);
            otherwise
                y=(x.^4)/4;
        end
    case "rati"
        switch der
            case "der"
                y=x/(1+x.^2);
            case "der_der"
                y=(1-x.^2)/((1+x.^2).^2);
            otherwise
                y=log((x.^2)+1)/2;
        end
end


end