\l funq.q
\l stopwords.q
\l bible.q
\l moby.q
\l emma.q
\l pandp.q
\l sands.q
\l mansfield.q
\l northanger.q

-1 "cleaning and stemming text";
c:(.porter.stem each " " vs .util.stripstr lower .util.cleanstr@) peach moby.s
-1 "building a term document matrix from corpus and vocabulary (minus stopwords)";
sw:.porter.stem peach stopwords.xpo6
m:.ml.tdm[c] v:asc distinct[raze c] except sw
-1 "building a vector space model (with different examples of tf-idf)";
-1 "vanilla tf-idf";
vsm:0f^.ml.tfidf[::;.ml.idf] m
-1 "log normalized term frequency, inverse document frequency max";
vsm:0f^.ml.tfidf[.ml.lntf;.ml.idfm] m
-1 "double normalized term frequency, probabilistic inverse document frequency";
vsm:0f^.ml.tfidf[.ml.dntf[.5];.ml.pidf] m
-1 "display values of top words based on tf-idf";
show vsm@'idesc each vsm
-1 "display top words based on tf-idf";
show v 5#/:idesc each vsm

vsm:0f^.ml.tfidf[::;.ml.idf] m
X:.ml.normalize vsm
C:.ml.skmeans[X] -30?/:X
g:.ml.cgroup[.ml.cosdist;X;C] / classify

-1"using tfidf and nb to predict which jane austen book a chapter came from";

t:flip `text`class!(emma.s;`E)
t,:flip `text`class!(pandp.s;`P)
t,:flip `text`class!(sands.s;`S)
t,:flip `text`class!(mansfield.s;`M)
t,:flip `text`class!(northanger.s;`N)

-1"cleaning and stripping text";
t:update (.util.stripstr lower .util.cleanstr@) peach text from t
-1"tokenizng and stemming text";
t:update (.porter.stem each " " vs) peach text from t
-1"partitioning text between training and test";
d:`train`test!.ml.part[3 1] t
c:d . `train`text
y:d . `train`class
-1"generating vocabulary and term document matrix";
sw:.porter.stem peach stopwords.xpo6
X:0f^.ml.tfidf[.ml.lntf;.ml.idf] .ml.tdm[c] v:asc distinct[raze c] except sw
-1 "fitting multinomial naive bayes classifier";
pT:.ml.fitnb[.ml.wmultimle[1];(::);flip X;y]
-1"confirming accuracy";
ct:d . `test`text
yt:d . `test`class
Xt:0f^.ml.tfidf[.ml.lntf;.ml.idf] .ml.tdm[ct] v
avg yt=p:.ml.clfnb[1b;.ml.multill;pT] flip Xt
show select[>N] from ([]word:v)!flip last pT
