import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';

class PracticeLabFlow extends ConsumerStatefulWidget {
  const PracticeLabFlow({super.key});

  @override
  ConsumerState<PracticeLabFlow> createState() => _PracticeLabFlowState();
}

class _PracticeLabFlowState extends ConsumerState<PracticeLabFlow> {
  int _screen = 0;
  bool _tutorial = true;
  final _nameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _error;

  static const demoBalance = 50000;
  static const holder = 'Ayesha Demo';
  static const iban = 'PK00TECH0000001234567890';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _go(int i) => setState(() {
        _screen = i;
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TechSaathi Demo Bank'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _tutorial = !_tutorial),
            child: Text(_tutorial ? 'Hide tips' : 'Show tips'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.warning.withValues(alpha: 0.25),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'SIMULATION ONLY — NO REAL MONEY.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case 0:
        return _home();
      case 1:
        return _overview();
      case 2:
        return _beneficiaries();
      case 3:
        return _transfer();
      case 4:
        return _review();
      case 5:
        return _success();
      case 6:
        return _history();
      default:
        return _home();
    }
  }

  Widget _tip(String text) {
    if (!_tutorial) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TsCard(
        color: AppColors.secondaryTeal,
        padding: const EdgeInsets.all(14),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _home() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip('This is a practice bank. Nothing here is real.'),
        Text('Hello, $holder',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Demo balance: PKR 50,000',
            style: TextStyle(fontSize: 20, color: AppColors.primary)),
        const SizedBox(height: 20),
        TsButton(label: 'Account Overview', onPressed: () => _go(1)),
        const SizedBox(height: 10),
        TsButton(
            label: 'Beneficiaries',
            isPrimary: false,
            onPressed: () => _go(2)),
        const SizedBox(height: 10),
        TsButton(label: 'Transfer Money', onPressed: () => _go(3)),
        const SizedBox(height: 10),
        TsButton(
            label: 'Transaction History',
            isPrimary: false,
            onPressed: () => _go(6)),
      ],
    );
  }

  Widget _overview() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip('Account overview shows your name, balance, and IBAN.'),
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account holder: $holder',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Balance: PKR 50,000',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('IBAN: $iban', style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TsButton(label: 'Back to home', isPrimary: false, onPressed: () => _go(0)),
      ],
    );
  }

  Widget _beneficiaries() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip('A beneficiary is the person who receives the money.'),
        TsCard(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved demo beneficiaries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 12),
              Text('• Ahmed Demo — PK00FAKE111122223333',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 6),
              Text('• Fatima Demo — PK00FAKE444455556666',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TsButton(label: 'Start a transfer', onPressed: () => _go(3)),
        const SizedBox(height: 10),
        TsButton(label: 'Back', isPrimary: false, onPressed: () => _go(0)),
      ],
    );
  }

  Widget _transfer() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip('Fill each field carefully. You can correct mistakes.'),
        const Text('Transfer Money',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        const Text('Beneficiary (the person who receives the money)',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(hintText: 'e.g. Ahmed Demo'),
        ),
        const SizedBox(height: 14),
        const Text('Account number (fictional only)',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: _accountCtrl,
          decoration: const InputDecoration(hintText: 'e.g. 1234567890'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        const Text('Amount (how much you want to send)',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: _amountCtrl,
          decoration: const InputDecoration(hintText: 'e.g. 500'),
          keyboardType: TextInputType.number,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 16)),
        ],
        const SizedBox(height: 20),
        TsButton(
          label: 'Review transfer',
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final account = _accountCtrl.text.trim();
            final amount = int.tryParse(_amountCtrl.text.trim());
            if (name.isEmpty) {
              setState(() => _error = 'Please enter a beneficiary name.');
              return;
            }
            if (account.length < 6) {
              setState(() =>
                  _error = 'Account number looks too short. Please check it.');
              return;
            }
            if (amount == null || amount <= 0) {
              setState(() => _error = 'Enter a valid amount greater than 0.');
              return;
            }
            if (amount > demoBalance) {
              setState(() =>
                  _error = 'Amount is more than demo balance (PKR 50,000).');
              return;
            }
            _go(4);
          },
        ),
        const SizedBox(height: 10),
        TsButton(label: 'Cancel', isPrimary: false, onPressed: () => _go(0)),
      ],
    );
  }

  Widget _review() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip('Always check the recipient and amount before confirming.'),
        const Text('Review Transaction',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To: ${_nameCtrl.text}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Account: ${_accountCtrl.text}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Amount: PKR ${_amountCtrl.text}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TsButton(
          label: 'Confirm simulated transfer',
          onPressed: () async {
            await ref
                .read(userPreferencesProvider.notifier)
                .markPracticeComplete('demo_bank_transfer');
            _go(5);
          },
        ),
        const SizedBox(height: 10),
        TsButton(
            label: 'Go back and edit',
            isPrimary: false,
            onPressed: () => _go(3)),
      ],
    );
  }

  Widget _success() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.check_circle, size: 72, color: AppColors.success),
        const SizedBox(height: 16),
        const Text(
          'Transaction Successful (Simulation)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Demo receipt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Sent to: ${_nameCtrl.text}'),
              Text('Amount: PKR ${_amountCtrl.text}'),
              const Text('Reference: TS-DEMO-001'),
              const SizedBox(height: 8),
              const Text(
                'No real money was moved.',
                style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TsButton(label: 'View history', onPressed: () => _go(6)),
        const SizedBox(height: 10),
        TsButton(label: 'Back to Demo Bank home', isPrimary: false, onPressed: () => _go(0)),
      ],
    );
  }

  Widget _history() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _tip('History is a diary of money in and out.'),
        const Text('Transaction History',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (_nameCtrl.text.isNotEmpty)
          TsCard(
            child: Text(
              'Today — Sent PKR ${_amountCtrl.text.isEmpty ? '0' : _amountCtrl.text} to ${_nameCtrl.text} (simulation)',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        const SizedBox(height: 10),
        const TsCard(
          child: Text(
            'Yesterday — Received PKR 2,000 from Salary Demo',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        const TsCard(
          child: Text(
            '3 days ago — Paid PKR 1,500 Electricity Demo Bill',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
        TsButton(label: 'Back to home', onPressed: () => _go(0)),
      ],
    );
  }
}
