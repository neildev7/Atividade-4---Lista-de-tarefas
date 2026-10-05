import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Tarefas',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFA5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF00BFA5),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
        ),
      ),
      home: const TarefaScreen(),
    );
  }
}

class Tarefa {
  final String id;
  String titulo;
  bool concluida;
  bool prioridadeAlta;
  final DateTime criadaEm;

  Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
    this.prioridadeAlta = false,
    DateTime? criadaEm,
  }) : criadaEm = criadaEm ?? DateTime.now();
}

enum Filtro {
  todas,
  pendentes,
  concluidas,
}

class TarefaScreen extends StatefulWidget {
  const TarefaScreen({super.key});

  @override
  State<TarefaScreen> createState() => _TarefaScreenState();
}

class _TarefaScreenState extends State<TarefaScreen> {
  final List<Tarefa> _tarefas = [
    Tarefa(
      id: '1',
      titulo: 'Comprar pão, leite e ovo',
      prioridadeAlta: true,
    ),
    Tarefa(
      id: '2',
      titulo: 'Responder e-mails do trabalho',
      concluida: true,
    ),
    Tarefa(
      id: '3',
      titulo: 'Academia às 18h',
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  Filtro _filtroAtual = Filtro.todas;

  int get _tarefasPendentes {
    return _tarefas.where((tarefa) => !tarefa.concluida).length;
  }

  int get _tarefasConcluidas {
    return _tarefas.where((tarefa) => tarefa.concluida).length;
  }

  List<Tarefa> get _tarefasFiltradas {
    if (_filtroAtual == Filtro.pendentes) {
      return _tarefas.where((tarefa) => !tarefa.concluida).toList();
    }

    if (_filtroAtual == Filtro.concluidas) {
      return _tarefas.where((tarefa) => tarefa.concluida).toList();
    }

    return _tarefas;
  }

  void _abrirBottomSheet() {
    _controller.clear();

    bool prioridadeAlta = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, atualizarSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const Text(
                    'Nova tarefa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'O que precisa ser feito?',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00BFA5),
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      _adicionarTarefa(prioridadeAlta);
                    },
                  ),

                  const SizedBox(height: 12),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Prioridade alta'),
                    subtitle: const Text(
                      'Marcar esta tarefa como importante',
                    ),
                    value: prioridadeAlta,
                    activeThumbColor: const Color(0xFF00BFA5),
                    onChanged: (valor) {
                      atualizarSheet(() {
                        prioridadeAlta = valor;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      _adicionarTarefa(prioridadeAlta);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _adicionarTarefa(bool prioridadeAlta) {
    final texto = _controller.text.trim();

    if (texto.isEmpty) {
      return;
    }

    setState(() {
      _tarefas.add(
        Tarefa(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titulo: texto,
          prioridadeAlta: prioridadeAlta,
        ),
      );
    });

    _controller.clear();
    Navigator.pop(context);
  }

  void _alternarStatus(String id) {
    setState(() {
      final tarefa = _tarefas.firstWhere(
        (tarefa) => tarefa.id == id,
      );

      tarefa.concluida = !tarefa.concluida;
    });
  }

  void _alternarPrioridade(String id) {
    setState(() {
      final tarefa = _tarefas.firstWhere(
        (tarefa) => tarefa.id == id,
      );

      tarefa.prioridadeAlta = !tarefa.prioridadeAlta;
    });
  }

  void _deletarTarefa(String id) {
    final index = _tarefas.indexWhere(
      (tarefa) => tarefa.id == id,
    );

    if (index == -1) {
      return;
    }

    final tarefaRemovida = _tarefas[index];

    setState(() {
      _tarefas.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${tarefaRemovida.titulo}" foi removida',
        ),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () {
            setState(() {
              _tarefas.insert(index, tarefaRemovida);
            });
          },
        ),
      ),
    );
  }

  void _limparConcluidas() {
    if (_tarefasConcluidas == 0) {
      return;
    }

    setState(() {
      _tarefas.removeWhere((tarefa) => tarefa.concluida);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarefas concluídas removidas'),
      ),
    );
  }

  String _formatarHora(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tarefasVisiveis = _tarefasFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      appBar: AppBar(
        title: const Text('Lista de tarefas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_tarefasPendentes pendentes',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: _botaoFiltro(
                    'Todas',
                    Filtro.todas,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _botaoFiltro(
                    'Pendentes',
                    Filtro.pendentes,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _botaoFiltro(
                    'Concluídas',
                    Filtro.concluidas,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_tarefasConcluidas concluídas',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                if (_tarefasConcluidas > 0)
                  TextButton(
                    onPressed: _limparConcluidas,
                    child: const Text('Limpar concluídas'),
                  ),
              ],
            ),
          ),

          Expanded(
            child: tarefasVisiveis.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma tarefa encontrada',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 80,
                    ),
                    itemCount: tarefasVisiveis.length,
                    itemBuilder: (context, index) {
                      final tarefa = tarefasVisiveis[index];

                      return Dismissible(
                        key: ValueKey(tarefa.id),
                        direction: DismissDirection.endToStart,

                        background: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),

                        onDismissed: (_) {
                          _deletarTarefa(tarefa.id);
                        },

                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            leading: Checkbox(
                              value: tarefa.concluida,
                              activeColor: const Color(0xFF00BFA5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (_) {
                                _alternarStatus(tarefa.id);
                              },
                            ),

                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tarefa.titulo,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      decoration: tarefa.concluida
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: tarefa.concluida
                                          ? Colors.grey
                                          : const Color(0xFF2D2D2D),
                                    ),
                                  ),
                                ),

                                IconButton(
                                  tooltip: 'Alterar prioridade',
                                  onPressed: () {
                                    _alternarPrioridade(tarefa.id);
                                  },
                                  icon: Icon(
                                    tarefa.prioridadeAlta
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: tarefa.prioridadeAlta
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            subtitle: Row(
                              children: [
                                Text(
                                  tarefa.concluida
                                      ? 'Concluída'
                                      : 'Pendente',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tarefa.concluida
                                        ? const Color(0xFF00BFA5)
                                        : Colors.grey,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  '• ${_formatarHora(tarefa.criadaEm)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                if (tarefa.prioridadeAlta) ...[
                                  const SizedBox(width: 8),
                                  const Text(
                                    '• Alta',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirBottomSheet,
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _botaoFiltro(String texto, Filtro filtro) {
    final selecionado = _filtroAtual == filtro;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _filtroAtual = filtro;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selecionado
            ? const Color(0xFF00BFA5)
            : Colors.white,
        foregroundColor: selecionado
            ? Colors.white
            : const Color(0xFF2D2D2D),
        side: BorderSide(
          color: selecionado
              ? const Color(0xFF00BFA5)
              : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(texto),
    );
  }
}