FROM sdphaye/effective-san AS effective-san-eval

WORKDIR /home/EffectiveSan/spec2006
RUN sed -i 's/sudo //g' run-spec2006.sh
RUN mkdir /home/EffectiveSan/build/eval
WORKDIR /home/EffectiveSan/build/eval
COPY cpu2006-1.2.iso .
COPY runeffectivesan.sh .
CMD ["./runeffectivesan.sh"] 
