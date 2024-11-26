function color_multiply(color0, color1){
    var c1,c2,t;
    c1 = color0;
    c2 = color1;
    t = ((c1 & 255) * (c2 & 255)) >> 8;
    c1 = c1 >> 8;
    c2 = c2 >> 8;
    t |= ((c1 & 255) * (c2 & 255)) & 65280;
    c1 = c1 & 65280;
    c2 = c2 >> 8;
    t |= ((c1 * c2) & 16711680);
    return t;
}