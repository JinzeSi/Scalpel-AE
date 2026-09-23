///
/// Copyright (C) 2010-2013, Dependable Systems Laboratory, EPFL
/// Copyright (C) 2015, Cyberhaven
/// All rights reserved.
///
/// Licensed under the Cyberhaven Research License Agreement.
///

#ifndef S2E_PLUGINS_FunctionMonitor22_H
#define S2E_PLUGINS_FunctionMonitor22_H

#include <s2e/CorePlugin.h>
#include <s2e/Plugin.h>
#include <s2e/Plugins/OSMonitors/Support/ModuleExecutionDetector.h>
#include <s2e/S2EExecutionState.h>

#include <unordered_map>

namespace s2e {
namespace plugins {

class OSMonitor;

class FunctionMonitor2State;

class FunctionMonitor2 : public Plugin {
    S2E_PLUGIN
public:
    FunctionMonitor2(S2E *s2e) : Plugin(s2e) {
    }

    typedef sigc::signal<void, S2EExecutionState *> ReturnSignal;
    typedef sigc::signal<void, S2EExecutionState *, FunctionMonitor2State *> CallSignal;

    void initialize();

    CallSignal *getCallSignal(S2EExecutionState *state, uint64_t eip, uint64_t cr3 = 0);

    void registerReturnSignal(S2EExecutionState *state, FunctionMonitor2::ReturnSignal &sig);

    void eraseSp(S2EExecutionState *state, uint64_t pc);
    void disconnect(S2EExecutionState *state, const ModuleDescriptor &desc);

    template <typename T> static bool readParameter(S2EExecutionState *s, unsigned param, T *val) {
        uint64_t ptrSz = s->getPointerSize();
        return s->mem()->read(s->regs()->getSp() + (param + 1) * ptrSz, val, sizeof(*val));
    }

    static klee::ref<klee::Expr> readParameter(S2EExecutionState *s, unsigned paramIndex) {
        uint64_t ptrSz = s->getPointerSize();
        uint64_t paramAddress = s->regs()->getSp() + (paramIndex + 1) * ptrSz;
        return s->mem()->read(paramAddress, ptrSz * 8);
    }

    static bool writeParameter(S2EExecutionState *s, unsigned param, const klee::ref<klee::Expr> &val) {
        uint64_t ptrSz = s->getPointerSize();
        return s->mem()->write(s->regs()->getSp() + (param + 1) * ptrSz, val);
    }

protected:
    void slotTranslateBlockEnd(ExecutionSignal *, S2EExecutionState *state, TranslationBlock *tb, uint64_t pc, bool,
                               uint64_t);

    void slotModuleTranslateBlockEnd(ExecutionSignal *signal, S2EExecutionState *state, const ModuleDescriptor &module,
                                     TranslationBlock *tb, uint64_t pc, bool isStatic, uint64_t staticTarget);

    void slotTranslateJumpStart(ExecutionSignal *signal, S2EExecutionState *state, TranslationBlock *, uint64_t,
                                int jump_type);

    void slotCall(S2EExecutionState *state, uint64_t pc);
    void slotRet(S2EExecutionState *state, uint64_t pc);

    void slotTraceCall(S2EExecutionState *state, FunctionMonitor2State *fns);
    void slotTraceRet(S2EExecutionState *state, int f);

protected:
    OSMonitor *m_monitor;
    ModuleExecutionDetector *m_detector;
    bool m_localCalls;

    friend class FunctionMonitor2State;
};

class FunctionMonitor2State : public PluginState {

    struct CallDescriptor {
        uint64_t cr3;
        // TODO: add sourceModuleID and targetModuleID
        FunctionMonitor2::CallSignal signal;
    };

    struct ReturnDescriptor {
        // S2EExecutionState *state;
        uint64_t cr3;
        // TODO: add sourceModuleID and targetModuleID
        FunctionMonitor2::ReturnSignal signal;
    };
    typedef std::unordered_multimap<uint64_t, CallDescriptor> CallDescriptorsMap;
    typedef std::unordered_multimap<uint64_t, ReturnDescriptor> ReturnDescriptorsMap;

    CallDescriptorsMap m_callDescriptors;
    CallDescriptorsMap m_newCallDescriptors;
    ReturnDescriptorsMap m_returnDescriptors;

    FunctionMonitor2 *m_plugin;

    /* Get a signal that is emitted on function calls. Passing eip = 0 means
       any function, and cr3 = 0 means any cr3 */
    FunctionMonitor2::CallSignal *getCallSignal(uint64_t eip, uint64_t cr3 = 0);

    void slotCall(S2EExecutionState *state, uint64_t pc);
    void slotRet(S2EExecutionState *state, uint64_t pc, bool emitSignal);

    void disconnect(const ModuleDescriptor &desc, CallDescriptorsMap &descMap);
    void disconnect(const ModuleDescriptor &desc);

    bool exists(const CallDescriptorsMap &cdm, uint64_t eip, uint64_t cr3) const;

public:
    FunctionMonitor2State();
    virtual ~FunctionMonitor2State();
    virtual FunctionMonitor2State *clone() const;
    static PluginState *factory(Plugin *p, S2EExecutionState *s);

    void registerReturnSignal(S2EExecutionState *s, FunctionMonitor2::ReturnSignal &sig);

    friend class FunctionMonitor2;
};

#define FUNCMON_REGISTER_RETURN(state, fns, func)          \
    {                                                      \
        FunctionMonitor2::ReturnSignal returnSignal;        \
        returnSignal.connect(sigc::mem_fun(*this, &func)); \
        fns->registerReturnSignal(state, returnSignal);    \
    }

#define FUNCMON_REGISTER_RETURN_A(state, fns, func, ...)                            \
    {                                                                               \
        FunctionMonitor2::ReturnSignal returnSignal;                                 \
        returnSignal.connect(sigc::bind(sigc::mem_fun(*this, &func), __VA_ARGS__)); \
        fns->registerReturnSignal(state, returnSignal);                             \
    }

} // namespace plugins
} // namespace s2e

#endif // S2E_PLUGINS_FunctionMonitor22_H