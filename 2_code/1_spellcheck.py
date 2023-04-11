import jamspellpro

# requires swig@3
#   brew install swig@3
#   export PATH="/opt/homebrew/opt/swig@3/bin:$PATH"
# DOESNT RUN BECAUSE OF ABSEIL C++ REQUIREMENTS

corrector = jamspellpro.TSpellCorrector()
corrector.LoadLangModel('../../Models/JamSpell/model_de_big')

words = [x.replace("\n","") for x in open("1_data/phrases_for_jamspell.txt","r").readlines()]
correct = [corrector.FixFragment(word) for word in words]

with open('1_data/phrases_from_jamspell.txt','w') as f:
    for i in range(len(correct)):
        f.write(correct[i] + "\n")






