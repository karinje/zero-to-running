import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import Header from '../../src/components/Header';

describe('Header Component', () => {
  it('renders header text', () => {
    render(<Header />);
    // Adjust based on your actual Header component
    expect(screen.getByRole('banner')).toBeInTheDocument();
  });
});

